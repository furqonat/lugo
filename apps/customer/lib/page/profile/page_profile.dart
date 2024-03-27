import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lugo_customer/api/local_service.dart';
import 'package:lugo_customer/page/profile/controller_profile.dart';
import 'package:lugo_customer/route/route_name.dart';

class PageProfile extends GetView<ControllerProfile> {
  const PageProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(Get.height * 0.3),
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Obx(() => Stack(
                  children: <Widget>[
                    CachedNetworkImage(
                      width: Get.width,
                      height: Get.height * 0.3,
                      fit: BoxFit.cover,
                      imageUrl:
                          controller.controllerUser.user.value.avatar ?? '',
                      errorWidget: (context, url, error) => Image(
                          width: Get.width,
                          height: Get.height * 0.3,
                          fit: BoxFit.cover,
                          image: const AssetImage('assets/images/person.png')),
                    ),
                    Container(
                      width: Get.width,
                      height: Get.height * 0.3,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              end: Alignment.bottomCenter,
                              begin: Alignment.topCenter,
                              colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7)
                          ])),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                controller.controllerUser.user.value.name ??
                                    "user name",
                                style: GoogleFonts.readexPro(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                controller.controllerUser.user.value.email ??
                                    "user@email.com",
                                style: GoogleFonts.readexPro(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () =>
                                Get.toNamed(Routes.editProfile, arguments: {
                              'name':
                                  controller.controllerUser.user.value.name ??
                                      "",
                              'email':
                                  controller.controllerUser.user.value.email,
                              'phone':
                                  controller.controllerUser.user.value.phone,
                              'avatar':
                                  controller.controllerUser.user.value.avatar ??
                                      "",
                            }),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            child: Text(
                              "Edit Profile",
                              style: GoogleFonts.readexPro(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
          )),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 3));
          controller.getUser();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: ElevatedButton(
                    onPressed: () => controller.launchWhatsApp(),
                    style: ElevatedButton.styleFrom(
                        elevation: 5,
                        fixedSize: Size(Get.width, Get.height * 0.07),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF3978EF)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Whatsapp Admin",
                        style: GoogleFonts.readexPro(
                            fontSize: 12, color: Colors.white),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.aboutUs),
                    style: ElevatedButton.styleFrom(
                        elevation: 5,
                        fixedSize: Size(Get.width, Get.height * 0.07),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF3978EF)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Tentang kami",
                        style: GoogleFonts.readexPro(
                            fontSize: 12, color: Colors.white),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.privacyTerm),
                    style: ElevatedButton.styleFrom(
                        elevation: 5,
                        fixedSize: Size(Get.width, Get.height * 0.07),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF3978EF)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Kebijakan Privasi",
                        style: GoogleFonts.readexPro(
                            fontSize: 12, color: Colors.white),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: ElevatedButton(
                    onPressed: () async {
                      await LocalService().setIsBinding(isBinding: true);
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 5,
                        fixedSize: Size(Get.width, Get.height * 0.07),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF3978EF)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Bagikan",
                        style: GoogleFonts.readexPro(
                            fontSize: 12, color: Colors.white),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: ElevatedButton(
                    onPressed: () => controller.giveUsRate(context),
                    style: ElevatedButton.styleFrom(
                        elevation: 5,
                        fixedSize: Size(Get.width, Get.height * 0.07),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF3978EF)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Beri Rating",
                        style: GoogleFonts.readexPro(
                            fontSize: 12, color: Colors.white),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: ElevatedButton(
                    onPressed: () async {
                      await LocalService().removeStorageForLogout();
                      Get.offAllNamed(Routes.auth);
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 5,
                        fixedSize: Size(Get.width, Get.height * 0.07),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF3978EF)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Keluar",
                        style: GoogleFonts.readexPro(
                            fontSize: 12, color: Colors.white),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
