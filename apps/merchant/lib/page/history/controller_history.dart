import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lugo_marchant/page/history/api_history.dart';

enum Status { idle, loading, success, failed }

class ControllerHistory extends GetxController {
  final ApiHistory api;
  ControllerHistory({required this.api});

  final loading = Status.idle.obs;
  final orders = [].obs;
  final orderList = ["Hari Ini", "Minggu Ini", "Bulan Ini"].obs;

  final orderValue = "Hari Ini".obs;

  final _fbAuth = FirebaseAuth.instance;

  handleGetOrders([time = "day"]) async {
    final token = await _fbAuth.currentUser?.getIdToken();
    final resp = await api.getOrders(token: token!, time: time);
    log("response $resp");
    orders.value = resp;
    loading.value = Status.success;
  }

  @override
  void onInit() {
    super.onInit();
    loading.value = Status.loading;
    handleGetOrders();
  }
}
