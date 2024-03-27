import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lugo_customer/response/banner.dart';
import 'package:lugo_customer/shared/query_builder.dart';
import 'package:lugo_customer/shared/utils.dart';
import 'package:rest_client/cart_client.dart';
import 'package:rest_client/product_client.dart';
import '../../response/product.dart';
import 'api_menu.dart';

enum Status { idle, loading, success, failed }

class ControllerFoodMenu extends GetxController {
  final ApiFoodMenu api;
  final CartClient cartClient;
  final ProductClient productClient;
  ControllerFoodMenu({
    required this.api,
    required this.cartClient,
    required this.productClient,
  });

  var loading = Status.idle.obs;
  final firebase = FirebaseAuth.instance;

  var merchantId = ''.obs;
  var merchantAddress = ''.obs;

  RxList<Product> product = <Product>[].obs;
  final cart = Cart().obs;
  List<Map<String, dynamic>> favoriteStatus = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> listQuantity = <Map<String, dynamic>>[];

  var total = 0.obs;

  var listImg = [
    'assets/images/2023-05-12_(1).jpg',
    'assets/images/2023-05-12_(2).jpg'
  ];

  RxList<Banners> banner = <Banners>[].obs;

  var bannerLoader = false.obs;

  getProducts() async {
    var token = await firebase.currentUser?.getIdToken();
    loading(Status.loading);
    getCarts().then((value) async {
      final queryBuilder = QueryBuilder()
        ..addQuery("id", 'true')
        ..addQuery("name", "true")
        ..addQuery("description", "true")
        ..addQuery("price", "true")
        ..addQuery("image", "true")
        ..addQuery("_count", "true")
        ..addQuery("merchant_id", merchantId.value)
        ..addQuery("favorites", "true");
      try {
        final resp = await productClient.getProducts(
          bearerToken: "Bearer $token",
          queries: queryBuilder.toMap(),
        );
        log("response $resp");
        if (resp["data"] != null) {
          final list = resp["data"];
          product(
            RxList<Product>.from(
              list.map(
                (e) => Product.fromJson(e),
              ),
            ),
          );
          listQuantity = List.generate(product.length, (i) {
            final ff = cart.value.data?.cartItem?.firstWhereOrNull((element) {
              return element.productId == product[i].id;
            });
            if (ff != null) {
              total.value = total.value + (ff.quantity! * product[i].price!);
              return {'quantity': ff.quantity.obs};
            } else {
              return {'quantity': 0.obs};
            }
          });
          for (var i = 0; i < product.length; i++) {
            var status = product[i]
                .favorites!
                .where((it) => it.customerId == firebase.currentUser?.uid)
                .toList()
                .isNotEmpty;
            favoriteStatus.add({"status": status.obs});
          }
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
    });
  }

  Future<void> getCarts() async {
    final token = await firebase.currentUser?.getIdToken();
    try {
      final resp = await cartClient.getCarts("Bearer $token", {});
      cart.value = resp;
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
    }
  }

  addOrDeleteProductToFavorite(String idProduct, int index) async {
    favoriteStatus[index]['status'].value =
        !favoriteStatus[index]['status'].value;
    try {
      final token = await firebase.currentUser?.getIdToken();
      final resp = await productClient.addOrDeleteProductFromFavorite(
        bearerToken: "Bearer $token",
        productId: idProduct,
      );
      if (resp.message == "OK") {
      } else {
        Fluttertoast.showToast(msg: 'Ada yang salah');
      }
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
    }
  }

  detailProduct(String imageUrl, String productName, int price,
      String description, String productId, int index) {
    return showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        width: Get.width,
        height: Get.height * 0.75,
        child: Column(
          children: <Widget>[
            Container(
              height: 5,
              width: Get.width * 0.3,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(12)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  width: Get.width,
                  height: Get.height * 0.3,
                  imageUrl: imageUrl,
                  errorWidget: (context, url, error) => Image(
                      width: Get.width,
                      height: Get.height * 0.3,
                      fit: BoxFit.fitWidth,
                      image: const AssetImage('assets/images/sample_food.png')),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                productName,
                style: GoogleFonts.readexPro(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
              child: Text(
                convertToIdr(price, 0),
                style: GoogleFonts.readexPro(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                description,
                style: GoogleFonts.readexPro(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                addOrDeleteProductToFavorite(productId, index);
              },
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Card(
                      color: const Color(0xFF3978EF).withOpacity(0.7),
                      child: Obx(
                        () => Icon(
                          !favoriteStatus[index]['status'].value
                              ? Icons.favorite_border_rounded
                              : Icons.favorite,
                          color: !favoriteStatus[index]['status'].value
                              ? Colors.white
                              : Colors.pink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void handleIncreaseCart(int index) async {
    final token = await firebase.currentUser?.getIdToken();
    final qty = listQuantity[index]["quantity"].value;
    if (qty == 0) {
      listQuantity[index]["quantity"].value += 1;
      final currentQty = qty + 1 as int;
      total.value = total.value + (product[index].price! * currentQty);
      final body = {
        "productId": "${product[index].id}",
        "quantity": currentQty
      };
      final resp = await cartClient.addProductToCart("Bearer $token", body);
      log("message => ${resp.message}");
      return;
    }

    listQuantity[index]["quantity"].value += 1;
    final currentQty = qty as int;
    total.value = total.value + (product[index].price! * currentQty);
    final resp = await updateProductFromCart(
      "${product[index].id}",
      currentQty,
    );
    log("message => ${resp.message}");
  }

  void handleDecreaseCart(int index) async {
    if (listQuantity[index]["quantity"].value == 0) {
      total.value = 0;
      return;
    }
    if (listQuantity[index]["quantity"].value > 0) {
      listQuantity[index]["quantity"].value -= 1;
      final currentQty = listQuantity[index]["quantity"].value as int;
      if (currentQty == 0) {
        total.value = 0;
      } else {
        total.value -= (product[index].price! * currentQty);
      }
      final resp =
          await updateProductFromCart("${product[index].id}", currentQty);
      log("message > ${listQuantity[index]["quantity"].value} => ${resp.message}");
      return;
    } else {
      total.value = 0;
      listQuantity[index]["quantity"].value = 0;
      final resp = await updateProductFromCart("${product[index].id}", 0);
      log("message < 0 => ${resp.message}");
      return;
    }
  }

  updateProductFromCart(String productId, int quantity) async {
    final token = await firebase.currentUser?.getIdToken();
    final resp = await cartClient.updateProductFromCart(
        "Bearer $token", {"productId": productId, "quantity": quantity});
    return resp;
  }

  getBanner() async {
    try {
      bannerLoader(true);
      var token = await firebase.currentUser?.getIdToken();
      var r = await api.getBanner(token: token!);
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

  @override
  void onInit() async {
    merchantId.value = Get.arguments["merchantId"];
    merchantAddress.value = Get.arguments["merchantAddress"];
    getProducts();
    getBanner();
    super.onInit();
  }
}
