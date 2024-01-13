package services

import (
	"apps/order/db"
	"context"
	"time"
)

type TotalOrder struct {
	TotalDone   int     `json:"done"`
	TotalCancel int     `json:"cancel"`
	TotalIncome float64 `json:"income"`
}

func (order OrderService) MerchantAcceptOrder(orderId string) error {
	_, errGetOrder := order.database.Order.FindUnique(
		db.Order.ID.Equals(orderId),
	).Update(
		db.Order.OrderStatus.Set(db.OrderStatusFindDriver),
	).Exec(context.Background())
	if errGetOrder != nil {
		return nil
	}
	err := order.updateTrxStatusOnFirestore(orderId, string(db.OrderStatusFindDriver))
	if err != nil {
		return err
	}
	return nil
}

func (order OrderService) MerchantRejectOrder(orderId string) error {
	_, errGetOrder := order.database.Order.FindUnique(
		db.Order.ID.Equals(orderId),
	).Update(
		db.Order.OrderStatus.Set(db.OrderStatusCanceled),
	).Exec(context.Background())
	if errGetOrder != nil {
		return nil
	}

	_, err := order.CancelOrder(orderId, "Merchant rejected or not responding")
	if err != nil {
		return err
	}
	errFrs := order.updateTrxStatusOnFirestore(orderId, string(db.OrderStatusCanceled))
	if errFrs != nil {
		return errFrs
	}
	return nil
}

func (order OrderService) GetAvaliableOrderForMerchant(merchantId string, take, skip int) ([]db.OrderModel, error) {
	orders, err := order.database.Order.FindMany(
		db.Order.OrderItems.Every(
			db.OrderItem.Product.Where(
				db.Product.MerchantID.Equals(merchantId),
			),
		),
	).With(
		db.Order.Customer.Fetch(),
		db.Order.Transactions.Fetch(),
		db.Order.OrderDetail.Fetch(),
		db.Order.OrderItems.Fetch(),
	).Exec(context.Background())

	if err != nil {
		return nil, err
	}
	return orders, nil
}

func (order OrderService) MerchantGetSellStatusInDay(merchantId string) (*TotalOrder, error) {
	totalCanceled, errorCancel := order.getSellStatusInDay(merchantId, db.OrderStatusCanceled)
	if errorCancel != nil {
		return nil, errorCancel
	}

	totalDone, errorDone := order.getSellStatusInDay(merchantId, db.OrderStatusDone)
	if errorDone != nil {
		return nil, errorCancel
	}

	totalIncome, errIncome := order.getMerchantIncomeInDay(merchantId)
	if errIncome != nil {
		return nil, errIncome
	}
	return &TotalOrder{
		TotalDone:   totalDone,
		TotalCancel: totalCanceled,
		TotalIncome: float64(totalIncome),
	}, nil

}

func (order OrderService) getSellStatusInDay(merchantId string, status db.OrderStatus) (int, error) {
	currentTime := time.Now()
	oneDayAgo := currentTime.Add(-24 * time.Hour)
	nextDay := currentTime.Add(24 * time.Hour)
	orderDb, errOrder := order.database.Order.FindMany(
		db.Order.CreatedAt.Gte(oneDayAgo),
		db.Order.CreatedAt.Lte(nextDay),
		db.Order.OrderItems.Some(
			db.OrderItem.Product.Where(
				db.Product.MerchantID.Equals(merchantId),
			),
		),
		db.Order.OrderStatus.Equals(status),
	).Exec(context.Background())
	if errOrder != nil {
		return 0, errOrder
	}
	return len(orderDb), nil
}

func (order OrderService) getMerchantIncomeInDay(merchantId string) (int, error) {
	currentTime := time.Now()
	oneDayAgo := currentTime.Add(-24 * time.Hour)
	nextDay := currentTime.Add(24 * time.Hour)
	orderDb, errOrder := order.database.MerchantTrx.FindMany(
		db.MerchantTrx.CreatedAt.Gte(oneDayAgo),
		db.MerchantTrx.CreatedAt.Lte(nextDay),
		db.MerchantTrx.MerchantID.Equals(merchantId),
	).Exec(context.Background())
	if errOrder != nil {
		return 0, errOrder
	}
	currentBalance := 0

	for _, b := range orderDb {
		currentBalance += b.Amount
	}
	return currentBalance, nil
}
