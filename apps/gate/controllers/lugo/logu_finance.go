package lugo

import (
	"apps/gate/db"
	"apps/gate/utils"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type PriceInKM struct {
	Distance    float64        `json:"distance"`
	ServiceType db.ServiceType `json:"service_type"`
}

type CreatTax struct {
	AppliedFor db.AppliedFor `json:"applied_for"`
	TaxType    db.TaxType    `json:"tax_type"`
	Amount     int           `json:"amount"`
}

type Withdraw struct {
	Amount int `json:"amount"`
}

func (c Controller) GetTrxFee(ctx *gin.Context) {
	service, err := c.service.GetTrxFee()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"data": service})
}

func (c Controller) CreateTrxFee(ctx *gin.Context) {
	model := db.ServiceFeeModel{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	service, errService := c.service.CreateTrxFee(&model)
	if errService != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + errService.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusCreated, gin.H{"message": "OK", "res": service})
}

func (c Controller) DeleteTrxFee(ctx *gin.Context) {
	feeId := ctx.Param("id")
	if err := c.service.DeleteFee(feeId); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"message": "OK"})
}

func (c Controller) UpdateTrxFee(ctx *gin.Context) {
	feeId := ctx.Param("id")
	model := db.ServiceFeeModel{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	fee, err := c.service.UpdateTrxFee(feeId, &model)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"message": "OK", "res": fee})
}

func (c Controller) GetPriceInKm(ctx *gin.Context) {
	model := PriceInKM{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	service, err := c.service.PriceInKM(model.Distance, model.ServiceType)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"message": "OK", "price": service})
}

func (c Controller) CreateTax(ctx *gin.Context) {
	model := CreatTax{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	service, err := c.service.CreateTax(model.AppliedFor, model.TaxType, model.Amount)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{"message": "OK", "res": service})
}

func (c Controller) GetTax(ctx *gin.Context) {
	s, err := c.service.GetTax()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, s)
}

func (c Controller) UpdateTax(ctx *gin.Context) {
	taxId := ctx.Param("taxId")
	model := db.TaxModel{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}

	service, err := c.service.UpdateTax(taxId, &model)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"message": "OK", "res": service})
}

func (c Controller) DeleteTax(ctx *gin.Context) {
	taxId := ctx.Param("taxId")
	if err := c.service.DeleteTax(taxId); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"message": "OK"})
}

func (c Controller) CreateKorlapFee(ctx *gin.Context) {
	model := db.KorlapFeeModel{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	s, err := c.service.CreateKorlapFee(&model)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusCreated, s)
}

func (c Controller) UpdateKorlapFee(ctx *gin.Context) {
	id := ctx.Param("id")
	model := db.KorlapFeeModel{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	s, err := c.service.UpdateKorlapFee(id, &model)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusCreated, gin.H{"message": "OK", "res": s})
}

func (c Controller) DeleteKorlapFee(ctx *gin.Context) {
	id := ctx.Param("id")

	err := c.service.DeleteKorlapFee(id)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusCreated, gin.H{"message": "OK"})
}

func (c Controller) GetKorlapFee(ctx *gin.Context) {
	qTake := ctx.Query("take")
	qSkip := ctx.Query("skip")
	take, errT := strconv.Atoi(qTake)
	if errT != nil {
		take = 20
	}
	skip, errS := strconv.Atoi(qSkip)
	if errS != nil {
		skip = 0
	}

	fees, total, err := c.service.GetKorlapFee(take, skip)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"data": fees, "total": total})
}

func (c Controller) GetCompanyBallance(ctx *gin.Context) {
	s, err := c.service.GetCompanyBallance()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, s)
}

func (c Controller) CreateDiscount(ctx *gin.Context) {
	model := db.DiscountModel{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	s, err := c.service.CreateDiscount(&model)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusCreated, s)
}

func (c Controller) GetDiscounts(ctx *gin.Context) {
	s, err := c.service.GetDiscount()
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, s)
}

func (c Controller) DeleteDiscount(ctx *gin.Context) {
	id := ctx.Param("id")
	if err := c.service.DeleteDiscount(id); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"message": "OK"})
}

func (c Controller) AdminRequestWithdraw(ctx *gin.Context) {
	adminId := ctx.GetString(utils.UID)
	model := Withdraw{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	result, err := c.service.AdminRequestWithdraw(adminId, model.Amount)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, result)
}

func (c Controller) MerchantRequestWithdraw(ctx *gin.Context) {
	merchantId := ctx.GetString(utils.UID)
	model := Withdraw{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	result, err := c.service.MerchantRequestWithdraw(merchantId, model.Amount)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, result)
}

func (c Controller) DriverRequestWithdraw(ctx *gin.Context) {
	driverId := ctx.GetString(utils.UID)
	model := Withdraw{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	result, err := c.service.DriverRequestWithdraw(driverId, model.Amount)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, result)
}

func (c Controller) MerchantTopUp(ctx *gin.Context) {
	merchatId := ctx.GetString(utils.UID)
	model := Withdraw{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	res, err := c.service.MerchantTopUp(merchatId, model.Amount)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, res)
}

func (c Controller) DriverTopUp(ctx *gin.Context) {
	driverId := ctx.GetString(utils.UID)
	model := Withdraw{}
	if err := ctx.BindJSON(&model); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	res, err := c.service.DriverTopUp(driverId, model.Amount)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, res)
}

func (c Controller) GetTrxCompany(ctx *gin.Context) {

	trxType := ctx.Query("type")
	res, err := c.service.GetCompanyBalanceTrx(trxType)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, res)
}

// func (c Controller) GetBonusDrivers(ctx *gin.Context) {
// 	res, err := c.service.GetBonusDrivers()
// 	if err != nil {
// 		c.logger.Info(err.Error())
// 		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
// 		ctx.Abort()
// 		return
// 	}
// 	ctx.JSON(http.StatusOK, res)
// }

// func (c Controller) GetBonusDriver(ctx *gin.Context) {
// 	id := ctx.Param("id")
// 	res, err := c.service.GetBonusDriver(id)
// 	if err != nil {
// 		ctx.JSON(http.StatusInternalServerError, gin.H{"message": "Unexpected error :" + err.Error()})
// 		ctx.Abort()
// 		return
// 	}
// 	ctx.JSON(http.StatusOK, res)
// }
