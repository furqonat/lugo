package services

import (
	"apps/order/db"
	"apps/order/utils"
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/messaging"
)

type OrderService struct {
	database    utils.Database
	firestore   Firestore
	messaging   Messaging
	danaService DanaService
}

type CreateOrderType struct {
	db.OrderModel
	Product     []Inner  `json:"product,omitempty"`
	Location    Location `json:"location,omitempty"`
	Destination Location `json:"destination,omitempty"`
}

type Inner struct {
	ProductId *string `json:"product_id,omitempty"`
	Quantity  *int    `json:"quantity,omitempty"`
}

type Location struct {
	Address   string  `json:"address"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type QueryRawNearly struct {
	DriverID        string  `json:"driver_id"`
	DriverLatitude  float64 `json:"driver_lat"`
	DriverLongitude float64 `json:"driver_lon"`
	Distance        float64 `json:"distance"`
}

func NewOrderService(database utils.Database, firestore Firestore) *OrderService {
	return &OrderService{
		database:  database,
		firestore: firestore,
	}
}

func (order OrderService) deleteOrder(orderId string) (*db.OrderModel, error) {
	return order.database.Order.FindUnique(db.Order.ID.Equals(orderId)).Delete().Exec(context.Background())
}

func (order OrderService) deleteTrx(orderId string) (*db.TransactionsModel, error) {
	return order.database.Transactions.FindUnique(db.Transactions.ID.Equals(orderId)).Delete().Exec(context.Background())
}

func (order OrderService) CreateOrder(ptrOrderModel *CreateOrderType, customerId string) (*string, *db.TransactionDetailModel, error) {

	orderExists, err := order.database.Order.FindMany(
		db.Order.CustomerID.Equals(customerId),
		db.Order.OrderStatus.NotIn([]db.OrderStatus{
			db.OrderStatusDone,
			db.OrderStatusCanceled,
		}),
		db.Order.OrderType.Equals(ptrOrderModel.OrderType),
	).Take(1).Exec(context.Background())

	if err != nil {
		return nil, nil, err
	}

	if len(orderExists) > 0 {
		orderDb, errOrder := order.database.Order.FindUnique(db.Order.ID.Equals(orderExists[0].ID)).With(db.Order.Transactions.Fetch().With(db.Transactions.Detail.Fetch())).Exec(context.Background())
		if errOrder != nil {
			return nil, nil, errOrder
		}
		trx, okTrx := orderDb.Transactions()
		if !okTrx {
			return nil, nil, errors.New("unable fetch transactions")
		}
		detail, okDetail := trx.Detail()
		if !okDetail {
			return nil, nil, errors.New("unable fetch transactions detail")
		}

		return &trx.OrderID, detail, nil
	}

	createOrderResult, errCreateOrder := order.database.Order.CreateOne(
		db.Order.OrderType.Set(ptrOrderModel.OrderType),
		db.Order.PaymentType.Set(ptrOrderModel.PaymentType),
		db.Order.Customer.Link(db.Customer.ID.Equals(customerId)),
		db.Order.GrossAmount.Set(ptrOrderModel.GrossAmount),
		db.Order.NetAmount.Set(ptrOrderModel.NetAmount),
		db.Order.TotalAmount.Set(ptrOrderModel.TotalAmount),
		db.Order.ShippingCost.Set(ptrOrderModel.ShippingCost),
	).Exec(context.Background())

	if errCreateOrder != nil {
		return nil, nil, errCreateOrder
	}

	if ptrOrderModel.OrderType == db.ServiceTypeFood || ptrOrderModel.OrderType == db.ServiceTypeMart {
		for _, product := range ptrOrderModel.Product {

			if product.ProductId == nil {
				order.deleteOrder(createOrderResult.ID)
				return nil, nil, errors.New("product id not found")
			}

			if product.Quantity != nil && *product.Quantity == 0 {
				order.deleteOrder(createOrderResult.ID)
				return nil, nil, errors.New("quantity must be greater than 0")
			}

			if product.Quantity == nil {
				order.deleteOrder(createOrderResult.ID)
				return nil, nil, errors.New("please provide quantity")
			}
			_, errCreateOrderItem := order.database.OrderItem.CreateOne(
				db.OrderItem.Product.Link(db.Product.ID.EqualsIfPresent(product.ProductId)),
				db.OrderItem.Quantity.SetIfPresent(product.Quantity),
				db.OrderItem.Order.Link(db.Order.ID.Equals(createOrderResult.ID)),
			).Exec(context.Background())

			if errCreateOrderItem != nil {
				order.deleteOrder(createOrderResult.ID)
				return nil, nil, errCreateOrderItem
			}
		}
	}
	_, errCreateOrderDetail := order.database.OrderDetail.CreateOne(
		db.OrderDetail.Order.Link(db.Order.ID.Equals(createOrderResult.ID)),
		db.OrderDetail.Latitude.Set(ptrOrderModel.Location.Longitude),
		db.OrderDetail.Longitude.Set(ptrOrderModel.Location.Longitude),
		db.OrderDetail.Address.Set(ptrOrderModel.Location.Address),
		db.OrderDetail.DstLatitude.Set(ptrOrderModel.Destination.Latitude),
		db.OrderDetail.DstLongitude.Set(ptrOrderModel.Destination.Longitude),
		db.OrderDetail.DstAddress.Set(ptrOrderModel.Destination.Address),
	).Exec(context.Background())
	if errCreateOrderDetail != nil {
		order.deleteOrder(createOrderResult.ID)
		return nil, nil, errCreateOrderDetail
	}
	trx, errCreateTrx := order.database.Transactions.CreateOne(
		db.Transactions.Type.Set(createOrderResult.OrderType),
		db.Transactions.Order.Link(db.Order.ID.Equals(createOrderResult.ID)),
	).Exec(context.Background())

	if errCreateTrx != nil {
		_, err := order.deleteOrder(createOrderResult.ID)
		if err != nil {
			return nil, nil, err
		}
		return nil, nil, errCreateTrx
	}

	errCreateTrxFirestore := order.createTrxOnFirestore(createOrderResult, trx)

	if errCreateTrxFirestore != nil {
		order.deleteTrx(trx.ID)
		order.deleteOrder(createOrderResult.ID)
		return nil, nil, errCreateTrxFirestore
	}
	if ptrOrderModel.PaymentType == db.PaymentTypeDana {
		currentTime := time.Now()

		// Add 1 hour to the current time
		oneHourLater := currentTime.Add(time.Hour)

		formattedTime := oneHourLater.Format(utils.DanaDateFormat)

		data, errDana := order.danaService.CreateNewOrder(
			formattedTime,
			"transactionType",
			fmt.Sprintf("Order:%s", ptrOrderModel.OrderType),
			createOrderResult.ID,
			ptrOrderModel.TotalAmount*100,
			"riskObjectId",
			"riskObjectCode",
			"riskObjectOperator",
			"",
		)
		if errDana != nil {
			order.deleteTrx(trx.ID)
			order.deleteOrder(createOrderResult.ID)
			return nil, nil, errDana
		}
		createTrxDetail, errCreateTrxDetail := order.database.TransactionDetail.CreateOne(
			db.TransactionDetail.Transactions.Link(db.Transactions.ID.Equals(trx.ID)),
			db.TransactionDetail.CheckoutURL.Set(data.CheckoutUrl),
			db.TransactionDetail.AcquirementID.Set(data.AcquirementId),
			db.TransactionDetail.MerchantTransID.Set(data.MerchantTransId),
		).Exec(context.Background())
		if errCreateTrxDetail != nil {
			return nil, nil, errCreateTrxDetail
		}
		return &createOrderResult.ID, createTrxDetail, nil
	} else {
		return &createOrderResult.ID, nil, nil

	}
}

func (order OrderService) CancelOrder(orderId string, reason string) (*string, error) {
	_, err := order.danaService.CancelOrder(orderId, reason)
	if err != nil {
		return nil, err
	}
	orderDb, errOrder := order.database.Order.FindUnique(
		db.Order.ID.Equals(orderId),
	).With(
		db.Order.Transactions.Fetch(),
	).Update(
		db.Order.OrderStatus.Set(db.OrderStatusCanceled),
	).Exec(context.Background())
	if errOrder != nil {
		return nil, errOrder
	}
	trx, okTrx := orderDb.Transactions()

	if !okTrx {
		return nil, errors.New("unable fetch transactions")
	}
	_, errUpdateTrx := order.database.Transactions.FindUnique(
		db.Transactions.ID.Equals(trx.ID),
	).Update(
		db.Transactions.Status.Set(db.TransactionStatusCanceled),
	).Exec(context.Background())

	if errUpdateTrx != nil {
		return nil, errUpdateTrx
	}
	_, er := order.firestore.Client.Collection("transactions").Doc(orderId).Update(context.Background(), []firestore.Update{
		{
			Path:  "status",
			Value: db.OrderStatusCanceled,
		},
	})
	if er != nil {
		return nil, er
	}
	return &trx.ID, nil
}

func (order OrderService) GetAvaliableOrder(take, skip int) ([]db.OrderModel, int, error) {
	orders, errGetOrders := order.database.Order.FindMany(
		db.Order.Showable.Equals(true),
		db.Order.DriverID.IsNull(),
		db.Order.OrderStatus.In([]db.OrderStatus{
			db.OrderStatusCreated,
			db.OrderStatusFindDriver,
		}),
	).With(
		db.Order.OrderDetail.Fetch(),
	).Take(take).Skip(skip).Exec(context.Background())

	total, errTotalOrders := order.database.Order.FindMany(
		db.Order.Showable.Equals(true),
		db.Order.DriverID.IsNull(),
		db.Order.OrderStatus.In([]db.OrderStatus{
			db.OrderStatusCreated,
			db.OrderStatusFindDriver,
		}),
	).Exec(context.Background())
	if errGetOrders != nil {
		return nil, 0, errGetOrders
	}

	if errTotalOrders != nil {
		return nil, 0, errTotalOrders
	}
	return orders, len(total), nil
}

func (order OrderService) FindGoodAndNearlyDriver(orderId string, latitude, longitude float64) error {
	orderDb, err := order.database.Order.FindUnique(db.Order.ID.Equals(orderId)).Exec(context.Background())
	if err != nil {
		return err
	}
	rejectedOrder, errRejectedOrder := order.database.OrderRejected.FindMany(
		db.OrderRejected.OrderID.Equals(orderId),
	).Exec(context.Background())
	if errRejectedOrder != nil {
		return errRejectedOrder
	}
	var disableDriverId []string
	for _, rejected := range rejectedOrder {
		driverId, okDriverId := rejected.DriverID()
		if okDriverId {
			disableDriverId = append(disableDriverId, driverId)
		}
	}
	query := fmt.Sprintf(`
	SELECT *
	FROM (
		SELECT
  		  driver_details.driver_id,
  		  current_lat AS driver_lat,
  		  current_lng AS driver_lon,
  		  ST_DistanceSphere(
  		    ST_SetSRID(ST_MakePoint(current_lng::FLOAT, current_lat::FLOAT), 4326),
  		    ST_SetSRID(ST_MakePoint(%f, %f), 4326)
  		  ) AS distance
		FROM
		  driver_details
		JOIN driver
		  ON driver.id = driver_details.driver_id
		JOIN driver_wallet
		  ON driver.id = driver_wallet.driver_id
		JOIN driver_settings
		  ON driver.id = driver_settings.driver_id
		WHERE driver_wallet.balance > %d
		AND driver.status = 'ACTIVE'
		AND driver_settings.auto_bid = TRUE
		AND driver.is_online = TRUE
		 %s
		 %s
	) AS subquery
	WHERE distance < 15000 
	ORDER BY
	  distance
	LIMIT 1
	`,
		longitude,
		latitude,
		orderDb.TotalAmount,
		order.driverSettings(orderDb.OrderType, orderDb.TotalAmount),
		order.rejectedDriver(disableDriverId),
	)
	res := []QueryRawNearly{}
	errQuery := order.database.Prisma.QueryRaw(query).Exec(context.Background(), &res)
	if errQuery != nil {
		return errQuery
	}
	if len(res) > 0 {
		_, errLinkDriver := order.LinkOrderWithDriver(orderId, res[0].DriverID)
		if errLinkDriver != nil {
			return errLinkDriver
		}
		driver, errGetDriver := order.database.Driver.FindUnique(
			db.Driver.ID.Equals(res[0].DriverID),
		).With(
			db.Driver.DeviceToken.Fetch(),
		).Exec(context.Background())
		if errGetDriver != nil {
			return errGetDriver
		}
		deviceToken, okDeviceToke := driver.DeviceToken()
		if !okDeviceToke {
			return errors.New("seem driver don't have a device token")
		}

		message := &messaging.Message{
			Data: map[string]string{
				"title":   "Kamu mendapatkan tugas baru!",
				"message": "Klik untuk mendapatkan detail",
			},
			Token: deviceToken.Token,
		}
		if _, err := order.messaging.Send(context.Background(), message); err != nil {
			return err
		}

		return nil
	}
	return nil
}

func (order OrderService) DriverSignOnOrder(orderId, driverId string) error {
	query := fmt.Sprintf(`
	UPDATE "order"
	SET driver_id = '%s' 
	WHERE id = '%s'
	AND driver_id IS NULL 
	`, driverId, driverId)
	_, err := order.database.Prisma.ExecuteRaw(query).Exec(context.Background())
	if err != nil {
		return err
	}
	orderDb, errGetOrderDb := order.database.Order.FindUnique(
		db.Order.ID.Equals(orderId),
	).With(
		db.Order.OrderItems.Fetch().With(
			db.OrderItem.Product.Fetch(),
		),
	).Exec(context.Background())

	if errGetOrderDb != nil {
		return errGetOrderDb
	}
	if err := order.updateTrxStatusOnFirestore(orderId, string(db.OrderStatusDriverOtw)); err != nil {
		return err
	}
	return order.sendMessageToApp(orderDb)
}

func (order OrderService) DriverRejectOrder(orderId string, driverId string) error {
	orderExists, errOrderExists := order.database.Order.FindUnique(db.Order.ID.Equals(orderId)).Exec(context.Background())
	if errOrderExists != nil {
		return errOrderExists
	}
	_, errCreteOrderReject := order.database.OrderRejected.CreateOne(
		db.OrderRejected.Order.Link(db.Order.ID.Equals(orderExists.ID)),
		db.OrderRejected.Driver.Link(db.Driver.ID.Equals(driverId)),
	).Exec(context.Background())

	_, errUpdateOrder := order.database.Order.FindUnique(
		db.Order.ID.Equals(orderId),
	).Update(
		db.Order.Driver.Unlink(),
		db.Order.Showable.Set(true),
	).Exec(context.Background())
	if errUpdateOrder != nil {
		return errUpdateOrder
	}
	if errCreteOrderReject != nil {
		return errCreteOrderReject
	}
	return nil
}

func (order OrderService) DriverAcceptOrder(orderId, driverId string) error {
	query := fmt.Sprintf(`
		UPDATE "order"
		SET driver_id = '%s' 
		WHERE id = '%s'
		AND driver_id IS NULL 
	`, driverId, driverId)
	_, errUpdateOrder := order.database.Prisma.ExecuteRaw(query).Exec(context.Background())
	if errUpdateOrder != nil {
		return errUpdateOrder
	}
	err := order.assignDriverOnFirestore(driverId, orderId)
	if err != nil {
		return err
	}
	if err := order.updateTrxStatusOnFirestore(orderId, string(db.OrderStatusDriverOtw)); err != nil {
		return err
	}
	return nil
}

func (order OrderService) LinkOrderWithDriver(orderId, driverId string) (*db.OrderModel, error) {
	linkDriver, errLinkDriver := order.database.Order.FindUnique(
		db.Order.ID.Equals(orderId),
	).Update(
		db.Order.Driver.Link(db.Driver.ID.Equals(driverId)),
	).Exec(context.Background())

	if errLinkDriver != nil {
		return nil, errLinkDriver
	}
	return linkDriver, nil
}

func (order OrderService) sendMessageToApp(orderModel *db.OrderModel) error {
	if orderModel.OrderType == db.ServiceTypeBike || orderModel.OrderType == db.ServiceTypeCar || orderModel.OrderType == db.ServiceTypeDelivery {
		return order.sendMessageToCustomer(orderModel.CustomerID, "Silahkan bersiap sebelum driver datang menjemputmu!")
	}
	if err := order.sendMessageToCustomer(orderModel.CustomerID, "Driver sedang menuju tempat, untuk menjemput pesananmu"); err != nil {
		return err
	}
	orderItem := orderModel.OrderItems()
	if len(orderItem) < 1 {
		return errors.New("mis match order type")
	}
	merchantId := orderItem[0].Product().MerchantID
	return order.sendMessageToMerchant(merchantId, "Berhasil mendapatkan driver", "Segera siapkan pesanan, sebelum driver tiba")
}

func (order OrderService) sendMessageToMerchant(merchantId, title, message string) error {
	merchant, errGetMerchant := order.database.Merchant.FindUnique(
		db.Merchant.ID.Equals(merchantId),
	).With(
		db.Merchant.DeviceToken.Fetch(),
	).Exec(context.Background())

	if errGetMerchant != nil {
		return errGetMerchant
	}
	deviceToken, okDeviceToken := merchant.DeviceToken()

	if !okDeviceToken {
		return errors.New("unable fetch merchant device token")
	}
	err := order.firebaseSendMessage(deviceToken.Token, title, message)
	if err != nil {
		return err
	}
	return nil
}

func (order OrderService) sendMessageToCustomer(customerId string, message string) error {
	customer, errGetCustomer := order.database.Customer.FindUnique(
		db.Customer.ID.Equals(customerId),
	).With(
		db.Customer.DeviceToken.Fetch(),
	).Exec(context.Background())
	if errGetCustomer != nil {
		return errGetCustomer
	}
	token, okToken := customer.DeviceToken()
	if !okToken {
		return errors.New("unable fetch customer device token")
	}
	err := order.firebaseSendMessage(token.Token, "Berhasil mendapatkan driver", message)
	if err != nil {
		return err
	}
	return nil
}

func (order OrderService) firebaseSendMessage(token, title, msg string) error {
	message := &messaging.Message{
		Data: map[string]string{
			"title":   title,
			"message": msg,
		},
		Token: token,
	}
	_, err := order.messaging.Send(context.Background(), message)
	if err != nil {
		return err
	}
	return nil
}

func (order OrderService) assignDriverOnFirestore(driverId, orderId string) error {
	_, err := order.firestore.Client.Collection("transactions").Doc(orderId).Update(
		context.Background(),
		[]firestore.Update{
			{
				Path:  "driver_id",
				Value: driverId,
			},
			{
				Path:  "status",
				Value: db.OrderStatusDriverOtw,
			},
		})
	if err != nil {
		return err
	}
	return nil
}

func (order OrderService) assignPtrStringIfTrue(value string, condition bool) *string {
	if condition {
		return &value
	}
	return nil
}

func (order OrderService) assignPtrTimeIfTrue(value time.Time, condition bool) *time.Time {
	if condition {
		return &value
	}
	return nil
}

func (order OrderService) createTrxOnFirestore(ptrOrderModel *db.OrderModel, ptrTrxModel *db.TransactionsModel) error {

	ptrEndedAt := order.assignPtrTimeIfTrue(ptrTrxModel.EndedAt())
	driverId := order.assignPtrStringIfTrue(ptrOrderModel.DriverID())

	_, errCreateTrxFirestore := order.firestore.Client.Collection("transactions").Doc(ptrOrderModel.ID).Set(context.Background(), map[string]interface{}{
		"id":           ptrTrxModel.ID,
		"driver_id":    driverId,
		"customer_id":  ptrOrderModel.CustomerID,
		"payment_type": ptrOrderModel.PaymentType,
		"payment_at":   nil,
		"order_type":   ptrOrderModel.OrderType,
		"status":       ptrTrxModel.Status,
		"created_at":   ptrTrxModel.CreatedAt,
		"ended_at":     ptrEndedAt,
	})
	if errCreateTrxFirestore != nil {
		errorMsg := fmt.Sprintf("unable to create transaction in firestore: %s", errCreateTrxFirestore.Error())
		return errors.New(errorMsg)
	}
	return nil
}

func (order OrderService) driverSettings(orderType db.ServiceType, price int) string {
	if orderType == db.ServiceTypeBike {
		return fmt.Sprintf("AND driver_settings.ride_price <= %d AND driver_settings.ride = TRUE", price)
	}
	if orderType == db.ServiceTypeDelivery {
		return fmt.Sprintf("AND driver_settings.delivery_price <= %d AND driver_settings.delivery = TRUE", price)
	}
	if orderType == db.ServiceTypeFood {
		return fmt.Sprintf("AND driver_settings.food_price <= %d AND driver_settings.food = TRUE", price)
	}
	if orderType == db.ServiceTypeMart {
		return fmt.Sprintf("AND driver_settings.mart_price <= %d AND driver_settings.mart = TRUE", price)
	} else {
		return ""
	}
}

func (order OrderService) rejectedDriver(driverIds []string) string {
	if len(driverIds) < 2 && len(driverIds) != 0 {
		return fmt.Sprintf("AND driver.id NOT IN ('%s')", driverIds[0])
	}
	if len(driverIds) > 1 {
		return fmt.Sprintf("AND driver.id NOT IN ('%s')", strings.Join(driverIds, "','"))
	}
	return ""
}

func (order OrderService) updateTrxStatusOnFirestore(orderId, status string) error {
	_, err := order.firestore.Client.Collection("transactions").Doc(orderId).Update(context.Background(), []firestore.Update{{
		Path:  "status",
		Value: status,
	}})

	if err != nil {
		return err
	}
	return nil
}
