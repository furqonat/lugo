import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lugo_marchant/api/local_service.dart';
import 'package:lugo_marchant/page/verification/controller.dart';
import 'package:lugo_marchant/route/route_name.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:validatorless/validatorless.dart';

Widget phoneVerification(
  BuildContext context,
  VerificationController controller,
) {
  return Scaffold(
    body: phoneVerificationView(context, controller),
  );
}

Widget phoneVerificationView(
    BuildContext context, VerificationController controller) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Text(
          "Nomor Telepon Anda",
          style: GoogleFonts.readexPro(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF14181B),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
        child: Text(
          "Masukan Nomor Telepon Anda Untuk Melanjutkan Verifikasi",
          style: GoogleFonts.readexPro(
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF14181B),
          ),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
        child: Form(
          key: controller.formPhoneVerification,
          child: TextFormField(
            autofocus: false,
            controller: controller.phoneNumber,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Nomor Telepon',
              labelStyle: GoogleFonts.readexPro(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF95A1AC),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFF4B39EF),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: const BorderSide(
                  width: 1,
                  color: Colors.grey,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFF1D2428),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: const BorderSide(width: 1, color: Colors.red),
              ),
              contentPadding: const EdgeInsets.all(24),
            ),
            validator: Validatorless.multiple(
              [
                Validatorless.required('Ponsel tidak boleh kosong'),
                Validatorless.regex(RegExp(r'^[1-9][0-9]{8,}$'),
                    'Ponsel tidak sesuai, cukup gunakan 813xxxxxxxx'),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ElevatedButton(
          onPressed: () {
            if (controller.formPhoneVerification.currentState!.validate()) {
              controller.handleVerificationPhone((verification) {
                controller.verificationId.value = verification;
                log(verification);
              }).then((value) {
                if (!controller.loadingPhoneVerification.value) {
                  bottomSheet(controller);
                }
                log(controller.verificationId.value);
              }).catchError((error) {
                Fluttertoast.showToast(msg: error.toString());
                log(error.toString());
              });
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 5,
            fixedSize: Size(Get.width * 0.5, Get.height * 0.07),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            backgroundColor: const Color(0xFF3978EF),
          ),
          child: controller.loadingPhoneVerification.value
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : Text(
                  "Masuk",
                  style:
                      GoogleFonts.readexPro(fontSize: 16, color: Colors.white),
                ),
        ),
      )
    ],
  );
}

void bottomSheet(VerificationController controller) {
  showModalBottomSheet(
    context: Get.context!,
    isDismissible: false,
    enableDrag: false,
    constraints: BoxConstraints.expand(width: Get.width, height: Get.height),
    builder: (context) => Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 60),
      child: Column(
        children: [
          Text(
            "PIN OTP",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              "Kode OTP sudah kami kirimkan menuju nomor telepon Anda\nJangan sebarkan kode ini kepada siapapun.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
          PinCodeTextField(
            length: 6,
            autoFocus: false,
            hintCharacter: '-',
            appContext: context,
            enableActiveFill: false,
            keyboardType: TextInputType.number,
            controller: controller.smsCode,
            textStyle: GoogleFonts.readexPro(
              fontSize: 12,
              color: const Color(0xFF4B39EF),
            ),
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            pinTheme: PinTheme(
              fieldHeight: 50.0,
              fieldWidth: 50.0,
              borderWidth: 2.0,
              borderRadius: BorderRadius.circular(12.0),
              shape: PinCodeFieldShape.box,
              activeColor: const Color(0xFF4B39EF),
              inactiveColor: const Color(0xFFF1F4F8),
              selectedColor: const Color(0xFF95A1AC),
              activeFillColor: const Color(0xFF4B39EF),
              inactiveFillColor: const Color(0xFFF1F4F8),
              selectedFillColor: const Color(0xFF95A1AC),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.verificationId.isEmpty) {
                Fluttertoast.showToast(msg: "Please wait until sms send");
                return;
              }
              controller
                  .handleContinueVerification(
                      controller.smsCode.text, controller.verificationId.value)
                  .then((value) {
                if (controller.verificationStatus.value.status) {
                  if (controller.verificationState ==
                      VerificationState.full.toString()) {
                    Get.back();
                    controller.activeStep.value = 1;
                  } else {
                    Get.back();
                    LocalService().setIsLogin(isLogin: true);
                    LocalService().setInVerification(false);
                    LocalService()
                        .setInVerificationStep(VerificationState.phoneOnly);
                    Get.offAllNamed(Routes.bottomNav);
                  }
                }
              });
            },
            style: ElevatedButton.styleFrom(
                elevation: 5,
                fixedSize: Size(Get.width * 0.5, Get.height * 0.07),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                backgroundColor: const Color(0xFF3978EF)),
            child: Text(
              "Lanjutkan",
              style: GoogleFonts.readexPro(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
