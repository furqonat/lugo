import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lugo_customer/page/food/api_food.dart';
import 'package:lugo_customer/response/banner.dart';
import 'package:lugo_customer/response/merchant.dart';

enum Status { idle, loading, success, failed }

class ControllerFood extends GetxController {
  final ApiFood api;
  ControllerFood({required this.api});

  var loading = Status.idle.obs;

  var bannerLoader = false.obs;

  var edtSearch = TextEditingController();

  var categoryTypeList = [
    "Kategori",
    "Makanan berat",
    "Makanan ringan",
    "Minuman",
  ].obs;

  var categoryType = "Kategori".obs;

  var listImg = [
    'assets/images/2023-05-12_(1).jpg',
    'assets/images/2023-05-12_(2).jpg'
  ];

  RxList<Merchant> merchant = <Merchant>[].obs;
  RxList<Merchant> searchMerchant = <Merchant>[].obs;

  final FirebaseAuth firebase = FirebaseAuth.instance;

  RxList<Banners> banner = <Banners>[].obs;

  @override
  void dispose() {
    edtSearch.dispose();
    super.dispose();
  }

  getMerchant() async {
    try {
      loading(Status.loading);
      var token = await firebase.currentUser?.getIdToken();
      var r = await api.getMerchant(token: token!);
      if (r["total"] != 0) {
        var list = r['data'];
        merchant(RxList<Merchant>.from(list.map((e) => Merchant.fromJson(e))));
        loading(Status.success);
      } else {
        loading(Status.failed);
      }
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
      loading(Status.failed);
    }
  }

  searchShop() {
    if (merchant.isNotEmpty && edtSearch.text.isNotEmpty) {
      for (var i in merchant) {
        var status =
            edtSearch.text.toLowerCase() == i.details?.name?.toLowerCase();
        if (status == true) {
          searchMerchant.add(i);
        } else {
          log('gagal');
        }
      }
    }
  }

  @override
  void onInit() {
    getMerchant();
    getBanner();
    super.onInit();
  }

  getBanner() async {
    try {
      bannerLoader(true);
      var token = await firebase.currentUser?.getIdToken();
      var r = await api.getBanner(token: token!);
      log("helo $r");
      if (r != null) {
        var list = r;
        banner(
            RxList<Banners>.from(list?.map((e) => Banners.fromJson(e)) ?? []));
        bannerLoader(false);
      } else {
        Fluttertoast.showToast(msg: "Ada yang salah");
        bannerLoader(false);
      }
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
      bannerLoader(false);
    }
  }
}
