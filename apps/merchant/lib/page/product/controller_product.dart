import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lugo_marchant/page/product/api_product.dart';
import 'package:lugo_marchant/response/category.dart';

import '../../response/product.dart';

enum Status { idle, loading, success, failed }

class ControllerProduct extends GetxController {
  final ApiProduct api;
  ControllerProduct({required this.api});

  var loading = Status.idle.obs;

  var category = "Kategori".obs;

  final firebase = FirebaseAuth.instance;

  final product = <Product>[].obs;
  final categories = <Category>[].obs;

  Future getCategories() async {
    final token = await firebase.currentUser?.getIdToken();
    final resp = await api.getCategories(token: token!);
    resp.add(Category(id: "", name: "Kategori"));
    categories(resp.map((e) => Category(id: e.id, name: e.name)).toList());
  }

  Future getProducts() async {
    try {
      loading(Status.loading);
      product.clear();
      var token = await firebase.currentUser?.getIdToken();
      var userId = firebase.currentUser?.uid;
      var r = await api.getProducts(
        token: token!,
        merchantId: userId!,
        filter: category.value == "Kategori" ? null : category.value,
      );
      if (r["data"] != null) {
        var list = r["data"]! as List<dynamic>;
        product(RxList<Product>.from(list.map((e) => Product.fromJson(e))));
        loading(Status.success);
      } else {
        Fluttertoast.showToast(msg: 'Ada yang salah');
        loading(Status.failed);
      }
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
      loading(Status.failed);
    }
  }

  handleSetEmptyProduct(String productId) async {
    final token = await firebase.currentUser?.getIdToken();
    final resp = await api.setEmptyProduct(
      token: token!,
      productId: productId,
    );
    if (resp.message == "OK") {
      await getProducts();
    }
  }

  @override
  void onInit() async {
    await getCategories();
    await getProducts();
    super.onInit();
  }
}
