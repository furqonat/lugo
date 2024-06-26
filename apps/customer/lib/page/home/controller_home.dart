import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lugo_customer/page/history_order/page_history.dart';
import 'package:lugo_customer/page/main_page/page_main.dart';
import 'package:lugo_customer/page/profile/page_profile.dart';
import 'package:lugo_customer/page/room_chat/page_roomchat.dart';
import 'package:lugo_customer/page/running_order/page_running.dart';

class ControllerHome extends GetxController {
  late PageController pageController;

  var currentPage = 0.obs;

  final List<Widget> pages = [
    const PageMain(),
    const PageRunning(),
    const PageHistory(),
    const PageRoomChat(),
    const PageProfile(),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: currentPage.value);
  }

  @override
  void onReady() {
    super.onReady();
    var pageArg = Get.arguments;
    if (pageArg != null) {
      changePage(pageArg);
      pageController.jumpToPage(pageArg);
    }
  }

  void changePage(index) => currentPage.value = index;
}
