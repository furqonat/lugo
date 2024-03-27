import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lugo_marchant/page/profile/api_profile.dart';
import 'package:lugo_marchant/response/user.dart';
import 'package:lugo_marchant/shared/custom_widget/lugo_btn.dart';

enum Status { idle, loading, success, failed }

class ControllerProfile extends GetxController {
  final ApiProfile api;
  ControllerProfile({required this.api});

  var storeOpen = false.obs;

  var loading = Status.idle.obs;

  final merchant = UserResponse().obs;
  final _fbAuth = FirebaseAuth.instance;

  Future getUser() async {
    try {
      loading(Status.loading);
      final firebaseToken = await _fbAuth.currentUser?.getIdToken();
      final r = await api.userDetail(token: firebaseToken!);
      if (r.id != null) {
        merchant.value = r;
        loading(Status.success);
      } else {
        Fluttertoast.showToast(msg: 'Something wrong');
        loading(Status.failed);
      }
    } catch (e) {
      loading(Status.failed);
    }
  }

  Future<void> handleUpdateStoreOpen(bool status) async {
    final token = await _fbAuth.currentUser?.getIdToken();
    getUser().then((value) async {
      if (merchant.value.status != 'ACTIVE') {
        Fluttertoast.showToast(
          msg: "unable update because you still in verification",
        );
        storeOpen.value = false;
        return;
      } else {
        storeOpen.value = true;
        await api.updateMerchantOpen(token: token!, status: status);
      }
    });
  }

  userHelp(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          width: Get.width,
          height: Get.height * 0.35,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                child: Text(
                    textAlign: TextAlign.center,
                    'Kontak & Informasi\nBantuan',
                    style: GoogleFonts.readexPro(
                      fontSize: 24,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                child: Row(
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                          style: GoogleFonts.readexPro(
                              fontSize: 14, color: Colors.black87),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Whatsapp ',
                            ),
                            TextSpan(
                              text: '081234567899',
                              style: GoogleFonts.readexPro(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                    ),
                    const Spacer(),
                    const Icon(Icons.phone_rounded, color: Colors.green)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                child: Row(
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                          style: GoogleFonts.readexPro(
                              fontSize: 14, color: Colors.black87),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Email ',
                            ),
                            TextSpan(
                                text: 'admin@email.com',
                                style: GoogleFonts.readexPro(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                )),
                          ]),
                    ),
                    const Spacer(),
                    const Icon(Icons.email_rounded, color: Colors.red)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  rateUs(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          width: Get.width,
          height: Get.height * 0.35,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 30),
                child: Text(
                  'Rate Us',
                  style: GoogleFonts.readexPro(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Berikan tanggapan anda terhadap kami',
                  style: GoogleFonts.readexPro(
                    fontSize: 12,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: AnimatedRatingStars(
                    starSize: 45,
                    onChanged: (p0) {},
                    customFilledIcon: Icons.star,
                    customHalfFilledIcon: Icons.star,
                    customEmptyIcon: Icons.star),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: LugoButton(
                    textButton: "Beri Nilai",
                    textColor: Colors.white,
                    textSize: 12,
                    width: Get.width,
                    height: Get.height * 0.06,
                    color: const Color(0xFF3978EF),
                    onTap: () {}),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void onInit() {
    getUser();
    super.onInit();
  }

  @override
  void onReady() {
    getUser();
    super.onReady();
  }
}
