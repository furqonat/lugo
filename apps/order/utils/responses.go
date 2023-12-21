package utils

type Result[T any] struct {
	Response InnerResult[T] `json:"response"`
}

type InnerResult[T any] struct {
	Head map[string]interface{} `json:"head"`
	Body T                      `json:"body"`
}

type ApplyToken struct {
	ResultInfo      ResultInfo      `json:"resultInfo"`
	AccessTokenInfo AccessTokenInfo `json:"accessTokenInfo"`
	UserInfo        UserInfo        `json:"userInfo"`
}

type UserProfile struct {
	ResultInfo        ResultInfo          `json:"resultInfo"`
	UserResourcesInfo []UserResourcesInfo `json:"userResourcesInfos"`
}

type CancelOrder struct {
	ResultInfo      ResultInfo `json:"resultInfo"`
	AcquirementId   string     `json:"acquirementId"`
	MerchantTransId string     `json:"merchantTransId"`
	CancelTime      string     `json:"cancelTime"`
}

type CreateOrder struct {
	ResultInfo      ResultInfo `json:"resultInfo"`
	MerchantTransId string     `json:"merchantTransId"`
	AcquirementId   string     `json:"acquirementId"`
	CheckoutUrl     string     `json:"checkoutUrl"`
}

type UserResourcesInfo struct {
	ResourceType string `json:"resourceType"`
	Value        string `json:"value"`
}

type UserInfo struct {
	PublicUserId string `json:"publicUserId"`
}

type AccessTokenInfo struct {
	AccessToken  string `json:"accessToken"`
	ExpiresIn    string `json:"expiresIn"`
	RefreshToken string `json:"refreshToken"`
	ReExpiresIn  string `json:"reExpiresIn"`
	TokenStatus  string `json:"tokenStatus"`
}

type ResultInfo struct {
	ResultStatus  string `json:"resultStatus"`
	ResultCodeId  string `json:"resultCodeId"`
	ResultCode    string `json:"resultCode"`
	ResultMessage string `json:"resultMsg"`
}