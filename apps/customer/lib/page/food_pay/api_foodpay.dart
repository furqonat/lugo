import 'dart:developer';

import 'package:lugo_customer/api/api_service.dart';

class ApiFoodPay {
  Future<dynamic> getCart({required String token}) async {
    var r =
        await ApiService().apiJSONGetWitFirebaseToken('cart', "cart", token);
    return r;
  }

  Future<dynamic> updateCart({
    required String productId,
    required int quantity,
    required String token,
  }) async {
    final body = {"productId": productId, "quantity": quantity};
    log("body : $body");
    var r = await ApiService()
        .apiJSONPutWithFirebaseToken('cart', 'cart', body, token);
    return r;
  }

  Future<dynamic> orderFoodMart({
    required String paymentType,
    required int grossAmount,
    required int netAmount,
    required int totalAmount,
    required int shippingCost,
    required List<Map<String, dynamic>> listProduct,
    required double latitude,
    required double longitude,
    required String address,
    required double dstlatitude,
    required double dstlongitude,
    required String dstaddress,
    required String discountId,
    required String token,
  }) async {
    dynamic r;

    final bodyDiscount = {
      "order_type": 'FOOD',
      "payment_type": paymentType,
      "gross_amount": grossAmount,
      "net_amount": netAmount,
      "total_amount": totalAmount,
      "shipping_cost": shippingCost,
      "product": listProduct,
      "location": {
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
      },
      "destination": {
        "latitude": dstlatitude,
        "longitude": dstlongitude,
        "address": dstaddress,
      },
      "discount_id": discountId
    };

    final body = {
      "order_type": 'FOOD',
      "payment_type": paymentType,
      "gross_amount": grossAmount,
      "net_amount": netAmount,
      "total_amount": totalAmount,
      "shipping_cost": shippingCost,
      "product": listProduct,
      "location": {
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
      },
      "destination": {
        "latitude": dstlatitude,
        "longitude": dstlongitude,
        "address": dstaddress,
      }
    };

    if (discountId.isEmpty || discountId == '') {
      r = await ApiService()
          .apiJSONPostWithFirebaseToken('order', '', body, token);
    } else {
      r = await ApiService()
          .apiJSONPostWithFirebaseToken('order', '', bodyDiscount, token);
    }

    return r;
  }

  Future<dynamic> setFee(
      {required double distance,
      required String serviceType,
      required String token}) async {
    final body = {"distance": distance, "service_type": serviceType};

    var r = await ApiService()
        .apiJSONPostWithFirebaseToken('gate', 'lugo/fee/distance', body, token);
    return r;
  }
}
