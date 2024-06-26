import 'dart:developer';

import 'package:lugo_marchant/response/category.dart';
import 'package:lugo_marchant/shared/servinces/url_service.dart';
import 'package:rest_client/product_client.dart';
import 'package:rest_client/shared.dart';

class ApiProduct {
  final ProductClient productClient;

  ApiProduct({required this.productClient});

  Future<dynamic> getProducts({
    required String token,
    required String merchantId,
    String? filter,
  }) async {
    final queryBuilder = QueryBuilder()
      ..addQuery("id", "true")
      ..addQuery("name", "true")
      ..addQuery("description", "true")
      ..addQuery("price", "true")
      ..addQuery("filter", filter)
      ..addQuery("merchant_id", merchantId)
      ..addQuery("image", "true")
      ..addQuery("category", "true")
      ..addQuery("_count", "{select: {customer_product_review: true}}");
    final resp = await productClient.getMerchantProducts(
      bearerToken: "Bearer $token",
      queries: queryBuilder.toMap(),
    );
    log("$resp");
    return resp;
  }

  Future<List<Category>> getCategories({required String token}) async {
    final resp = await productClient.getMerchantProductCategories(
      bearerToken: "Bearer $token",
    );
    return (resp['data'] as List<dynamic>)
        .map((e) => Category(id: e['id'], name: e['name']))
        .toList();
  }

  Future<Response> setEmptyProduct({
    required String token,
    required String productId,
  }) async {
    final body = {"status": false};
    final resp = await productClient.updateProduct(
      bearerToken: "Bearer $token",
      productId: productId,
      body: body,
    );
    return resp;
  }
}
