import 'dart:developer' as logger;
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:get/get.dart';
import 'package:google_maps_utils/spherical_utils.dart';
import 'package:location/location.dart';
import 'package:lugo_customer/api/local_service.dart';
import 'package:lugo_customer/page/food_menu/controller_menu.dart';
import 'package:lugo_customer/page/food_pay/api_foodpay.dart';
import 'package:lugo_customer/response/transaction.dart';
import 'package:lugo_customer/route/route_name.dart';

import '../../response/cart.dart';

enum Status { idle, loading, success, failed }

class ControllerFoodPay extends GetxController {
  final ApiFoodPay api;
  ControllerFoodPay({required this.api});

  var loading = Status.idle.obs;

  var edtDiscount = TextEditingController();

  var categoryTypeList = [
    "Pembayaran",
    "CASH",
    "DANA",
  ].obs;

  var categoryType = "Pembayaran".obs;

  var orderPrice = 0.obs;
  var shppingCost = 0.obs;
  final ctMenuFood = Get.find<ControllerFoodMenu>();

  final FirebaseAuth firebase = FirebaseAuth.instance;

  final Location location = Location();
  Rx<LocationData> myLocation =
      LocationData.fromMap({"latitude": 0.0, "longitude": 0.0}).obs;
  Rx<LocationData> merchantLocation =
      LocationData.fromMap({"latitude": 0.0, "longitude": 0.0}).obs;
  var distance = 0.0.obs;

  var merchantAddress = ''.obs;
  var address = ''.obs;

  Rx<Transactions> transactions = Transactions().obs;

  RxList<Cart> carts = <Cart>[].obs;
  List<Map<String, dynamic>> listQuantity = <Map<String, dynamic>>[];

  List<Map<String, dynamic>> inputList = [];

  getCarts() async {
    try {
      loading(Status.loading);
      var token = await firebase.currentUser?.getIdToken();
      carts.clear();
      orderPrice(0);
      var r = await api.getCart(token: token!);
      if (r["total"] != 0) {
        var items = r["data"]["cart_item"];
        carts(RxList<Cart>.from(items.map((e) => Cart.fromJson(e))));
        listQuantity = List.generate(carts.length, (i) {
          return {'quantity': carts[i].quantity.obs};
        });
        for (var j = 0; j < carts.length; j++) {
          int price = carts[j].product!.price!;
          int quantity = listQuantity[j]['quantity'].value;
          orderPrice.value += quantity * price;
        }
        loading(Status.success);
      } else {
        Get.back();
        loading(Status.failed);
      }
    } catch (e, stackTrace) {
      loading(Status.failed);
      Get.back();
      logger.log('$e');
      logger.log('$stackTrace');
    }
  }

  handleUpdateCart(String productId, int quantity) async {
    try {
      var token = await firebase.currentUser?.getIdToken();
      if (productId.isNotEmpty) {
        var r = await api.updateCart(
          productId: productId,
          quantity: quantity,
          token: token!,
        );
        if (r["message"] == "OK") {
          getCarts();
          ctMenuFood.getCarts();
        } else {
          logger.log("response : $r");
          Fluttertoast.showToast(msg: "Anda gagal merubah daftar belanja anda");
        }
      }
    } catch (e, stackTrace) {
      logger.log('$e');
      logger.log('$stackTrace');
    }
  }

  getLocation() => location.getLocation().then((value) {
        myLocation(LocationData.fromMap(
            {"latitude": value.latitude, "longitude": value.longitude}));

        geo.placemarkFromCoordinates(value.latitude!, value.longitude!).then(
            (value) => address.value =
                "${value.first.street}, ${value.first.subLocality}, ${value.first.locality}, ${value.first.administrativeArea}, ${value.first.country}, ${value.first.postalCode}");
      });

  getDestinationLocation() async {
    List<geo.Location> placemark =
        await geo.locationFromAddress(merchantAddress.value);

    for (var location in placemark) {
      merchantLocation.value = LocationData.fromMap({
        'latitude': location.latitude,
        'longitude': location.longitude,
      });
    }
  }

  handleDecrease(String productId, int index) {
    listQuantity[index]["quantity"].value == 0
        ? listQuantity[index]["quantity"].value = 0
        : listQuantity[index]["quantity"].value -= 1;
    handleUpdateCart(productId, listQuantity[index]["quantity"].value);
  }

  handleIncrease(String productId, int index) {
    listQuantity[index]["quantity"].value += 1;
    handleUpdateCart(productId, listQuantity[index]["quantity"].value);
  }

  setFee() async {
    try {
      var token = await firebase.currentUser?.getIdToken();

      double originalNumber = SphericalUtils.computeDistanceBetween(
        Point(myLocation.value.latitude!, myLocation.value.longitude!),
        Point(
          merchantLocation.value.latitude!,
          merchantLocation.value.longitude!,
        ),
      ).toDouble();

      var proccess = originalNumber / 1000;

      int decimalPlaces = 2;

      double roundedNumber =
          double.parse(proccess.toStringAsFixed(decimalPlaces));

      distance(roundedNumber);

      var r = await api.setFee(
          distance: distance.value, serviceType: 'FOOD', token: token!);
      if (r["message"] == "OK") {
        var value = r["price"];
        shppingCost.value = value;
      }
    } catch (e, stackTrace) {
      logger.log("$e");
      logger.log("$stackTrace");
    }
  }

  orderFoodMart() async {
    try {
      inputList.clear();
      var token = await firebase.currentUser?.getIdToken();
      for (int i = 0; i < carts.length; i++) {
        inputList.add({
          "quantity": listQuantity[i]['quantity'].value,
          "product_id": carts[i].productId,
        });
      }

      var totalAmount = orderPrice.value + shppingCost.value;

      final r = await api.orderFoodMart(
          paymentType: categoryType.value,
          grossAmount: orderPrice.value,
          netAmount: orderPrice.value,
          totalAmount: totalAmount,
          shippingCost: shppingCost.value,
          listProduct: inputList,
          latitude: myLocation.value.latitude!,
          longitude: myLocation.value.longitude!,
          address: address.value,
          dstlatitude: merchantLocation.value.latitude!,
          dstlongitude: merchantLocation.value.longitude!,
          dstaddress: merchantAddress.value,
          discountId: edtDiscount.text,
          token: token!);

      if (r["message"] == "Successfully create order") {
        var keeper = r;
        transactions.value = Transactions.fromJson(keeper);

        await LocalService()
            .setTransactionId(transaction: transactions.value.res);
        await LocalService().setRequestType(type: 'FOOD');
        await LocalService()
            .setPrice(prices: shppingCost.value + orderPrice.value);

        if (categoryType.value == 'DANA') {
          Get.offNamed(Routes.digitalPay, arguments: {
            'checkout_url': transactions.value.detail?.checkoutUrl,
            'request_type': 'FOOD',
            'latitude': myLocation.value.latitude,
            'longitude': myLocation.value.longitude,
            'order_id': r["kode_transaksi"],
            'price': orderPrice.value
          });
        } else {
          Get.offNamed(Routes.checkOrder, arguments: {
            'request_type': 'FOOD',
            'latitude': myLocation.value.latitude,
            'longitude': myLocation.value.longitude,
            'order_id': transactions.value.res,
            'price': orderPrice.value
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Tidak bisa membuat order");
        carts.clear();
        Get.back();
        logger.log("failed return => $r");
      }
    } catch (e, stackTrace) {
      logger.log('$e');
      logger.log('$stackTrace');
    }
  }

  @override
  void onInit() {
    merchantAddress.value = Get.arguments['merchantAddress'];
    logger.log(merchantAddress.value);
    getCarts();
    getLocation();
    getDestinationLocation();
    setFee();
    super.onInit();
  }
}
