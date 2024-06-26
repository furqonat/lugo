library rest_client;

import 'package:dio/dio.dart' show Dio, RequestOptions, ResponseType, Options;
import 'package:retrofit/retrofit.dart';

part 'gate_client.g.dart';

@RestApi(baseUrl: 'https://gate.gentatechnology.com/')
abstract class GateClient {
  factory GateClient(Dio dio, {String baseUrl}) = _GateClient;

  @GET("oauth")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future customerGetSignInUrl({
    @Header("Authorization") required String bearerToken,
  });
  @GET("oauth/merchant")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future merchantGetSignInUrl({
    @Header("Authorization") required String bearerToken,
  });
  @GET("oauth/driver")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future driverGetSignInUrl({
    @Header("Authorization") required String bearerToken,
  });

  @GET("oauth/profile")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future customerGetDanaProfile({
    @Header("Authorization") required String bearerToken,
  });
  @GET("oauth/merchant/profile")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future merchantGetDanaProfile({
    @Header("Authorization") required String bearerToken,
  });
  @GET("oauth/driver/profile")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future driverGetDanaProfile({
    @Header("Authorization") required String bearerToken,
  });

  @POST("lugo/driver/topup")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future driverTopUp({
    @Header("Authorization") required String bearerToken,
    @Body() required Map<String, dynamic> body,
  });

  @POST("lugo/driver/wd")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future driverWithdraw({
    @Header("Authorization") required String bearerToken,
    @Body() required Map<String, dynamic> body,
  });

  @POST("lugo/merchant/topup")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future merchantTopUp({
    @Header("Authorization") required String bearerToken,
    @Body() required Map<String, dynamic> body,
  });

  @POST("lugo/merchant/wd")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future merchantWithdraw({
    @Header("Authorization") required String bearerToken,
    @Body() required Map<String, dynamic> body,
  });

  @GET("lugo/banner")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future bannerMerchant({
    @Header("Authorization") required String bearerToken,
  });

  @GET("lugo/settings/sk-merchant")
  @Headers(<String, dynamic>{'Content-Type': 'application/json'})
  Future getSkMerchant({
    @Header("Authorization") required String bearerToken,
  });
}
