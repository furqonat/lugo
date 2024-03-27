import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:lugo_customer/page/food/controller_food.dart';
import 'package:lugo_customer/route/route_name.dart';
import 'package:shimmer/shimmer.dart';

class PageFood extends GetView<ControllerFood> {
  const PageFood({super.key});

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
            onTap: () => Get.offNamed(Routes.home),
            child: SizedBox(
              width: 55,
              height: 55,
              child: Card(
                elevation: 0,
                color: const Color(0xFF3978EF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                child: const Center(
                  child:
                      Icon(Icons.chevron_left, size: 24, color: Colors.white),
                ),
              ),
            )),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }

          Get.offNamed(Routes.home);
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: TextFormField(
                    controller: controller.edtSearch,
                    decoration: InputDecoration(
                      hintText: 'Mau makan apa?',
                      hintStyle: GoogleFonts.readexPro(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF95A1AC),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              width: 1, color: Color(0xFF4B39EF))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.grey)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              width: 1, color: Color(0xFF1D2428))),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.red)),
                      contentPadding: const EdgeInsets.all(24),
                      suffixIcon: IconButton(
                          onPressed: () => controller.searchShop(),
                          icon: const Icon(Icons.search_rounded)),
                    ),
                  ),
                ),
              ),
              Obx(
                () => !controller.bannerLoader.value &&
                        controller.banner.first.images != null
                    ? CarouselSlider.builder(
                        itemCount: controller.banner.first.images?.length,
                        options: CarouselOptions(
                          viewportFraction: 1,
                          autoPlay: true,
                          aspectRatio: 2,
                          initialPage: 0,
                        ),
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
              // Container(
              //   margin: const EdgeInsets.only(top: 10, bottom: 10),
              //   padding: const EdgeInsets.symmetric(horizontal: 10),
              //   decoration: BoxDecoration(
              //       border: Border.all(width: 1, color: Colors.grey),
              //       borderRadius: BorderRadius.circular(12)),
              //   child: DropdownButton<String>(
              //     elevation: 2,
              //     isExpanded: true,
              //     icon: const Icon(
              //       Icons.keyboard_arrow_down_rounded,
              //       color: Color(0xFF95A1AC),
              //       size: 24,
              //     ),
              //     underline: const SizedBox(),
              //     dropdownColor: Colors.white,
              //     value: controller.categoryType.value,
              //     items: controller.categoryTypeList.map((element) {
              //       return DropdownMenuItem(
              //         value: element,
              //         child: Text(
              //           element,
              //           style: GoogleFonts.poppins(
              //             fontSize: 12,
              //           ),
              //         ),
              //       );
              //     }).toList(),
              //     onChanged: (String? value) => controller.categoryType(value),
              //   ),
              // ),
              Expanded(child: Obx(() {
                if (controller.loading.value == Status.loading) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF3978EF)));
                } else if (controller.merchant.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Lottie.asset('assets/lottie/close.json'),
                        Text(
                          "Maaf ya, tidak toko yang buka",
                          style: GoogleFonts.readexPro(fontSize: 14),
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
                  if (controller.searchMerchant.isEmpty) {
                    return ListView.builder(
                      itemCount: controller.merchant.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => Get.toNamed(Routes.foodMenu, arguments: {
                            "merchantId": controller.merchant[index].id,
                            "merchantAddress":
                                controller.merchant[index].details?.address
                          }),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
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
                                      imageUrl: controller.merchant[index]
                                          .details!.images![0].link!,
                                      errorWidget: (context, url, error) =>
                                          const Image(
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                  'assets/images/sample_food.png')),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.merchant[index].details!.name!,
                                      style: GoogleFonts.readexPro(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Alamat',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                    SizedBox(
                                      width: Get.width * 0.65,
                                      child: Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        controller
                                            .merchant[index].details!.address!,
                                        style: GoogleFonts.readexPro(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      itemCount: controller.searchMerchant.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => Get.toNamed(Routes.foodMenu),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
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
                                      imageUrl: controller.searchMerchant[index]
                                          .details!.images![0].link!,
                                      errorWidget: (context, url, error) =>
                                          const Image(
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                  'assets/images/sample_food.png')),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nama toko',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                    Text(
                                      controller
                                          .searchMerchant[index].details!.name!,
                                      style: GoogleFonts.readexPro(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Alamat',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                    Text(
                                      controller.searchMerchant[index].details!
                                          .address!,
                                      style: GoogleFonts.readexPro(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
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
              }))
            ],
          ),
        ),
      ),
    );
  }
}
