import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lugo_customer/api/local_service.dart';
import 'package:lugo_customer/page/running_order/api_running.dart';
import 'package:lugo_customer/response/driver_profile.dart';
import 'package:lugo_customer/response/live_transaction.dart';

class ControllerRunning extends GetxController {
  final ApiRunning api;
  ControllerRunning({required this.api});

  var orderId = ''.obs;

  var price = 0.obs;

  final FirebaseAuth firebase = FirebaseAuth.instance;

  Rx<DriverProfile> driver = DriverProfile().obs;

  @override
  void onInit() async {
    var order = await LocalService().getTransactionId();
    var value = await LocalService().getPrice();

    if (value != null) {
      price.value = value;
    } else {
      price.value = 0;
    }

    if (order != null) {
      orderId.value = order;
    }

    super.onInit();
  }

  Future<DriverProfile?> findDriverDetail(String id) async {
    try {
      var token = await firebase.currentUser?.getIdToken();
      var r = await api.getDriver(driverId: id, token: token!);
      driver.value = DriverProfile.fromJson(r);
      return DriverProfile.fromJson(r);
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
      return null;
    }
  }

  Stream<LiveTransaction?>? trackTransaction() =>
      api.getOrder<LiveTransaction?>(
        documentId: orderId.value,
        fromJson: (data) => LiveTransaction.fromJson(data),
      );
}
