package routes

import (
	order "apps/order/controllers/order"
	"apps/order/middlewares"
	"apps/order/utils"
)

// OrderRoutes struct
type OrderRoutes struct {
	logger              utils.Logger
	handler             utils.RequestHandler
	rateLimitMiddleware middlewares.RateLimitMiddleware
	authMiddleware      middlewares.FirebaseMiddleware
	orderController     order.OrderController
}

// Setup Misc routes
func (s OrderRoutes) Setup() {
	s.logger.Info("Setting up routes")
	orderApi := s.handler.Gin.Group("/order").Use(s.rateLimitMiddleware.Handle())
	{
		orderApi.GET("/", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.FindOrders)
		orderApi.POST("/", s.authMiddleware.HandleAuthWithRoles(utils.USER), s.orderController.CreateOrder)
		orderApi.PUT("/driver/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.USER, utils.MERCHANT), s.orderController.FindDriver)
		orderApi.PUT("/driver/sign/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.DriverSignOnOrder)
		orderApi.PUT("/driver/reject/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.DriverRejectOrder)
		orderApi.PUT("/driver/accept/:orderId", s.authMiddleware.HandleAuthWithRoles(utils.DRIVER), s.orderController.DriverAccpetOrder)
		orderApi.PUT("/:id", s.authMiddleware.HandleAuthWithRoles(utils.USER, utils.MERCHANT), s.orderController.CancelOrder)
	}
}

// NewOrderRoutes creates new Misc controller
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
