package bootstrap

import (
	"context"

	"apps/gate/controllers"
	"apps/gate/middlewares"
	"apps/gate/routes"
	"apps/gate/services"
	"apps/gate/utils"

	"go.uber.org/fx"
)

// Module exported for initializing application
var Module = fx.Options(
	controllers.Module,
	routes.Module,
	utils.Module,
	services.Module,
	middlewares.Module,
	fx.Invoke(bootstrap),
)

func bootstrap(
	lifecycle fx.Lifecycle,
	handler utils.RequestHandler,
	routes routes.Routes,
	env utils.Env,
	logger utils.Logger,
	middlewares middlewares.Middlewares,
) {

	lifecycle.Append(fx.Hook{
		OnStart: func(context.Context) error {

			go func() {
				middlewares.Setup()
				routes.Setup()
				host := "0.0.0.0"

				// if env.Environment == "development" {
				// host = "127.0.0.1"
				err := handler.Gin.Run(host + ":" + env.ServerPort)
				if err != nil {
					return
				}
				// } else {
				// 	err := gateway.ListenAndServe(host, handler.Gin)
				// 	if err != nil {
				// 		return
				// 	}
				// }
			}()
			return nil
		},
		OnStop: func(context.Context) error {
			logger.Info("Stopping Application")
			return nil
		},
	})
}
