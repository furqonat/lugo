package routes

import (
	order "apps/order/controllers/order"
	"apps/order/middlewares"
	"apps/order/utils"
)

type OrderRoutes struct {
	logger              utils.Logger
	handler             utils.RequestHandler
	rateLimitMiddleware middlewares.RateLimitMiddleware
	authMiddleware      middlewares.FirebaseMiddleware
	orderController     order.OrderController
}

func (s OrderRoutes) Setup() {
	s.logger.Info("Setting up routes")
	orderApi := s.handler.Gin.Group("/").Use(s.rateLimitMiddleware.Handle())
	{
		orderApi.POST("/", s.authMiddleware.HandleAuthWithRoles(utils.USER), s.orderController.CreateOrder)

		orderApi.GET("/driver", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.FindOrders)
		orderApi.GET("/driver/history", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.DriverGetOrders)
		orderApi.PUT("/driver/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.USER, utils.MERCHANT), s.orderController.FindDriver)
		orderApi.PUT("/driver/sign/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.DriverSignOnOrder)
		orderApi.PUT("/driver/reject/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.DriverRejectOrder)
		orderApi.PUT("/driver/accept/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.DriverAccpetOrder)
		orderApi.PUT("/driver/finish/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.FinishOrder)
		orderApi.PUT("/driver/close/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.DriverClose)
		orderApi.PUT("/driver/shipping/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.DriverShipping)

		orderApi.PUT("/merchant/reject/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.MERCHANT), s.orderController.MerchantRejectOrder)
		orderApi.PUT("/merchant/accept/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.MERCHANT), s.orderController.MerchantAcceptOrder)
		orderApi.GET("/merchant", s.authMiddleware.HandleAuthWithRoles(utils.MERCHANT), s.orderController.MerchantGetOrders)
		orderApi.GET("/merchant/sell", s.authMiddleware.HandleAuthWithRoles(utils.MERCHANT), s.orderController.MerchantGetOrderInThisDay)
		orderApi.GET("/merchant/order", s.authMiddleware.HandleAuthWithRoles(utils.MERCHANT), s.orderController.MerchantGetOrderSellThisDay)
		orderApi.GET("/merchant/period", s.authMiddleware.HandleAuthWithRoles(utils.MERCHANT), s.orderController.MerchantGetOrderInPeriod)
		orderApi.GET("/customer", s.authMiddleware.HandleAuthWithRoles(utils.USER), s.orderController.CustomerGetOrders)

		orderApi.PUT("/:id", s.authMiddleware.HandleAuthWithRoles(utils.USER, utils.MERCHANT), s.orderController.CancelOrder)
		orderApi.GET("/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER, utils.MERCHANT, utils.USER), s.orderController.GetOrder)
	}
}

func NewOrderRoutes(
	logger utils.Logger,
	handler utils.RequestHandler,
	rateLimitMiddleware middlewares.RateLimitMiddleware,
	authMiddleware middlewares.FirebaseMiddleware,
	orderController order.OrderController,
) OrderRoutes {
	return OrderRoutes{
		handler:             handler,
		logger:              logger,
		rateLimitMiddleware: rateLimitMiddleware,
		authMiddleware:      authMiddleware,
		orderController:     orderController,
	}
}
