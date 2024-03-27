import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:lugo_customer/shared/utils.dart';
import 'package:shimmer/shimmer.dart';
import '../../route/route_name.dart';
import 'controller_menu.dart';

class PageFoodMenu extends GetView<ControllerFoodMenu> {
  const PageFoodMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: InkWell(
          onTap: () => Get.back(),
          child: SizedBox(
            width: 55,
            height: 55,
            child: Card(
              elevation: 0,
              color: const Color(0xFF3978EF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              child: const Center(
                child: Icon(Icons.chevron_left, size: 24, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Obx(
              () => controller.bannerLoader.value == false &&
                      controller.banner.first.images?.length != null
                  ? CarouselSlider.builder(
                      itemCount: controller.banner.first.images?.length,
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
                              imageUrl:
                                  controller.banner.first.images![index].link ??
                                      '',
                              errorWidget: (context, url, error) => Image(
                                fit: BoxFit.fill,
                                width: Get.width,
                                image: AssetImage(
                                  controller.listImg.first,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : SizedBox(
                      height: Get.height * 0.2,
                      width: Get.width,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.white,
                        child: const Card(elevation: 0),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Daftar Menu",
                style: GoogleFonts.readexPro(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.loading.value == Status.loading) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF3978EF)));
                } else if (controller.product.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Lottie.asset('assets/lottie/no_item.json')),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Maaf ya, tidak ada barang yang dijual",
                            style: GoogleFonts.readexPro(fontSize: 14),
                          ),
                        )
                      ],
                    ),
                  );
                } else if (controller.loading.value == Status.failed) {
                  return Center(
                    child: Text(
                      "Ada yang salah",
                      style: GoogleFonts.openSans(
                        fontSize: 20,
                      ),
                    ),
                  );
                } else if (controller.loading.value == Status.success) {
                  return ListView.builder(
                    itemCount: controller.product.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                        child: InkWell(
                          onTap: () => controller.detailProduct(
                            "${controller.product[index].image}",
                            "${controller.product[index].name}",
                            controller.product[index].price ?? 0,
                            "${controller.product[index].description}",
                            "${controller.product[index].id}",
                            index,
                          ),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        '${controller.product[index].image}',
                                    errorWidget: (context, url, error) =>
                                        const Image(
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                          'assets/images/sample_food.png'),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${controller.product[index].name}",
                                    style: GoogleFonts.readexPro(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    convertToIdr(
                                        controller.product[index].price, 0),
                                    style: GoogleFonts.readexPro(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  AnimatedRatingStars(
                                    starSize: 12,
                                    readOnly: true,
                                    initialRating: double.parse(
                                        "${controller.product[index].count?.customerProductReview}"),
                                    onChanged: (p0) {},
                                    customEmptyIcon: Icons.star_rounded,
                                    customFilledIcon: Icons.star_rounded,
                                    customHalfFilledIcon: Icons.star_rounded,
                                  )
                                ],
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 70,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Obx(
                                      () => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          InkWell(
                                            onTap: () {
                                              controller
                                                  .handleDecreaseCart(index);
                                            },
                                            child: const Icon(
                                              CupertinoIcons.minus_circle_fill,
                                              color: Color(0xFF3978EF),
                                              size: 32,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              "${controller.listQuantity[index]["quantity"].value}",
                                              style: GoogleFonts.readexPro(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller
                                                  .handleIncreaseCart(index);
                                            },
                                            child: const Icon(
                                              CupertinoIcons.add_circled_solid,
                                              color: Color(0xFF3978EF),
                                              size: 32,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text(
                      "Ada yang salah",
                      style: GoogleFonts.openSans(
                        fontSize: 20,
                      ),
                    ),
                  );
                }
              }),
            ),
            Obx(
              () => InkWell(
                onTap: () {
                  Get.toNamed(Routes.foodPay, arguments: {
                    "merchantAddress": controller.merchantAddress.value
                  });
                },
                child: Container(
                  width: Get.width,
                  height: Get.height * 0.07,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFF3978EF),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Icon(Icons.shopping_bag_rounded,
                          color: Colors.white),
                      Text(
                        convertToIdr(controller.total.value, 0),
                        style: GoogleFonts.readexPro(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
