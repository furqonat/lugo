import 'package:lugo_customer/api/api_service.dart';
import 'package:rest_client/cart_client.dart';
import 'package:rest_client/shared.dart';

class ApiFoodMenu {
  final CartClient cartClient;

  ApiFoodMenu({required this.cartClient});

  Future<dynamic> getProducts(
      {required String token, required String merchantId}) async {
    var r = await ApiService().apiJSONGetWitFirebaseToken(
        'product',
        '?id=true&name=true&description=true&price=true&merchant_id=$merchantId&image=true&_count={select: {customer_product_review: true}}&favorites={select: {customer_id: true}}',
        token);
    return r;
  }

  Future<dynamic> postLikeProduct(
      {required String productId, required String token}) async {
    var r = await ApiService()
        .apiJSONGetWitFirebaseToken('product', 'favorite/$productId', token);
    return r;
  }

  Future<Response> cart({
    required String productId,
    required int quantity,
    required String token,
  }) async {
    final body = {'productId': productId, 'quantity': quantity};
    final resp = await cartClient.addProductToCart("Bearer $token", body);
    return resp;
  }

  Future<dynamic> getBanner({required String token}) async => await ApiService()
      .apiJSONGetWitFirebaseToken('gate', 'lugo/banner', token);
}
