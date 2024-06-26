package routes

import "go.uber.org/fx"

// Module exports dependency to container
var Module = fx.Options(
	fx.Provide(NewRoutes),
	fx.Provide(NewMiscRoutes),
	fx.Provide(NewManagementRoutes),
	fx.Provide(NewLugoRoutes),
	fx.Provide(NewOAuthRoutes),
)

// Routes contains multiple routes
type Routes []Route

// Route interface
type Route interface {
	Setup()
}

// NewRoutes sets up routes
func NewRoutes(
	miscRoutes MiscRoutes,
	lugoRoutes LugoRoutes,
	oauthRoutes OAuthRoutes,
	management ManagementRoutes,
) Routes {
	return Routes{
		miscRoutes,
		lugoRoutes,
		oauthRoutes,
		management,
	}
}

// Setup all the route
func (r Routes) Setup() {
	for _, route := range r {
		route.Setup()
	}
}
