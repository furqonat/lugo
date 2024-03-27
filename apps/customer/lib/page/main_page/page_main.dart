import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lugo_customer/page/main_page/controller_main.dart';
import 'package:lugo_customer/route/route_name.dart';
import 'package:lugo_customer/shared/utils.dart';
import 'package:shimmer/shimmer.dart';

class PageMain extends GetView<ControllerMain> {
  const PageMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Obx(() => Text(
              "Halo, ${controller.controllerUser.user.value.name ?? 'Selamat datang'}",
              style: GoogleFonts.readexPro(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3978EF),
              ),
            )),
        actions: [
          IconButton(
              onPressed: () async => controller.checkorder(),
              icon: const Icon(CupertinoIcons.map))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Obx(() {
              if (controller.loading.value == false) {
                return controller.banner.first.images != null
                    ? SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: CarouselSlider.builder(
                            itemCount: controller.banner.first.images!.length,
                            options: CarouselOptions(
                                viewportFraction: 1,
                                autoPlay: true,
                                aspectRatio: 2,
                                initialPage: 0),
                            itemBuilder: (context, index, realIndex) {
                              return Padding(
                                padding: const EdgeInsets.all(5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                      width: Get.width,
                                      fit: BoxFit.fill,
                                      height: Get.height * 0.3,
                                      imageUrl: controller.banner.first
                                              .images![index].link ??
                                          '',
                                      errorWidget: (context, url, error) =>
                                          Image(
                                              fit: BoxFit.fill,
                                              width: Get.width,
                                              image: AssetImage(
                                                  controller.listImg.first))),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: CarouselSlider.builder(
                            itemCount: controller.listImg.length,
                            options: CarouselOptions(
                                viewportFraction: 1,
                                autoPlay: true,
                                aspectRatio: 2,
                                initialPage: 0),
                            itemBuilder: (context, index, realIndex) {
                              return Padding(
                                padding: const EdgeInsets.all(5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image(
                                      fit: BoxFit.fill,
                                      width: Get.width,
                                      image:
                                          AssetImage(controller.listImg.first)),
                                ),
                              );
                            },
                          ),
                        ),
                      );
              } else {
                return SizedBox(
                  height: Get.height * 0.2,
                  width: Get.width,
                  child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.white,
                      child: const Card(elevation: 0)),
                );
              }
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Get.offAllNamed(Routes.saldo);
                  },
                  child: Container(
                    width: Get.width * 0.47,
                    height: Get.height * 0.08,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: const Color(0xFF3978EF),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      "E-wallet Dana",
                      style: GoogleFonts.readexPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.onProgress(context),
                  child: Container(
                    width: Get.width * 0.47,
                    height: Get.height * 0.08,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: const Color(0xFF3978EF),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      "Coming Soon",
                      style: GoogleFonts.readexPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(width: 1, color: Colors.grey.shade300)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: GestureDetector(
                        onTap: () {
                          if (controller.orderLimit.value == false) {
                            Get.offAllNamed(Routes.locationPicker,
                                arguments: {"request_type": "BIKE"});
                          } else {
                            Fluttertoast.showToast(
                                msg:
                                    "Anda masih memiliki pesanan yang sedang berjalan");
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Image(
                              width: 50,
                              height: 50,
                              image: AssetImage(
                                  'assets/images/2023-05-05__2_-removebg-preview.png'),
                            ),
                            Text(
                              "Lu-Ride",
                              style: GoogleFonts.readexPro(
                                color: const Color(0xFF3978EF),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: GestureDetector(
                        onTap: () {
                          if (controller.orderLimit.value == false) {
                            Get.offAllNamed(Routes.locationPicker,
                                arguments: {"request_type": "CAR"});
                          } else {
                            Fluttertoast.showToast(
                                msg:
                                    "Anda masih memiliki pesanan yang sedang berjalan");
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Image(
                              width: 50,
                              height: 50,
                              image:
                                  AssetImage('assets/images/1696044585451.png'),
                            ),
                            Text(
                              "Lu-Car",
                              style: GoogleFonts.readexPro(
                                color: const Color(0xFF3978EF),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: GestureDetector(
                        onTap: () {
                          if (controller.orderLimit.value == false) {
                            Get.offAllNamed(Routes.locationPicker,
                                arguments: {"request_type": "DELIVERY"});
                          } else {
                            Fluttertoast.showToast(
                                msg:
                                    "Anda masih memiliki pesanan yang sedang berjalan");
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Image(
                              width: 50,
                              height: 50,
                              image: AssetImage(
                                  'assets/images/2023-05-05__2_-removebg-preview.png'),
                            ),
                            Text(
                              "Lu-Deliv",
                              style: GoogleFonts.readexPro(
                                color: const Color(0xFF3978EF),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: GestureDetector(
                        onTap: () {
                          if (controller.orderLimit.value == false) {
                            Get.offAllNamed(Routes.food,
                                arguments: {"request_type": "FOOD"});
                          } else {
                            Fluttertoast.showToast(
                                msg:
                                    "Anda masih memiliki pesanan yang sedang berjalan");
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Image(
                              width: 50,
                              height: 50,
                              image: AssetImage(
                                  'assets/images/2023-05-05__1_-removebg-preview.png'),
                            ),
                            Text(
                              "Lu-Food",
                              style: GoogleFonts.readexPro(
                                color: const Color(0xFF3978EF),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: GestureDetector(
                        onTap: () {
                          if (controller.orderLimit.value == false) {
                            Get.offAllNamed(Routes.mart,
                                arguments: {"request_type": "MART"});
                          } else {
                            Fluttertoast.showToast(
                                msg:
                                    "Anda masih memiliki pesanan yang sedang berjalan");
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Image(
                              width: 50,
                              height: 50,
                              image: AssetImage(
                                  'assets/images/2023-05-05-removebg-preview.png'),
                            ),
                            Text(
                              "Lu-Mart",
                              style: GoogleFonts.readexPro(
                                color: const Color(0xFF3978EF),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (controller.loading.value == false) {
                return controller.banner.first.images?.length != null
                    ? CarouselSlider.builder(
                        itemCount: controller.banner.first.images!.length,
                        options: CarouselOptions(
                            viewportFraction: 1,
                            autoPlay: true,
                            aspectRatio: 2,
                            initialPage: 0),
                        itemBuilder: (context, index, realIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                  width: Get.width,
                                  fit: BoxFit.fill,
                                  height: Get.height * 0.3,
                                  imageUrl: controller
                                          .banner.first.images![index].link ??
                                      '',
                                  errorWidget: (context, url, error) => Image(
                                      fit: BoxFit.fill,
                                      width: Get.width,
                                      image: AssetImage(
                                          controller.listImg.first))),
                            ),
                          );
                        },
                      )
                    : CarouselSlider.builder(
                        itemCount: controller.listImg.length,
                        options: CarouselOptions(
                            viewportFraction: 1,
                            autoPlay: true,
                            aspectRatio: 2,
                            initialPage: 0),
                        itemBuilder: (context, index, realIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image(
                                  fit: BoxFit.fill,
                                  width: Get.width,
                                  image: AssetImage(controller.listImg.first)),
                            ),
                          );
                        },
                      );
              } else {
                return SizedBox(
                  height: Get.height * 0.2,
                  width: Get.width,
                  child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.white,
                      child: const Card(elevation: 0)),
                );
              }
            }),
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 0, 5),
                      child: Text(
                        "Rekomendasi untuk anda",
                        style: GoogleFonts.readexPro(
                          fontSize: 16,
                          color: const Color(0xFF3978EF),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: controller.product.isNotEmpty
                            ? CarouselSlider.builder(
                                itemCount: controller.product.length,
                                options: CarouselOptions(
                                  initialPage: 0,
                                  autoPlay: true,
                                  viewportFraction: 0.5,
                                ),
                                itemBuilder: (context, index, realIndex) {
                                  if (controller.productLoading.value ==
                                      false) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Stack(
                                        children: <Widget>[
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              width: Get.width,
                                              height: Get.height * 0.22,
                                              fit: BoxFit.cover,
                                              imageUrl: controller
                                                      .product[index].image ??
                                                  "",
                                              errorWidget: (context, url,
                                                      error) =>
                                                  const Image(
                                                      image: AssetImage(
                                                          "assets/images/empty_image.jpg")),
                                            ),
                                          ),
                                          Container(
                                            width: Get.width,
                                            height: Get.height * 0.22,
                                            decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black38
                                                    ]),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            padding: const EdgeInsets.only(
                                                left: 12, bottom: 12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  controller.product[index]
                                                          .name ??
                                                      "Rekomendasi Produk",
                                                  style: GoogleFonts.readexPro(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  convertToIdr(
                                                      controller
                                                          .product[index].price,
                                                      0),
                                                  style: GoogleFonts.readexPro(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      width: Get.width,
                                      height: Get.height * 0.22,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Shimmer.fromColors(
                                          baseColor: Colors.grey.shade300,
                                          highlightColor: Colors.white,
                                          child: const Card(elevation: 0)),
                                    );
                                  }
                                },
                              )
                            : Center(
                                child: Text(
                                  "Tidak produk untuk ditawarkan",
                                  style: GoogleFonts.readexPro(fontSize: 12),
                                ),
                              )),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
