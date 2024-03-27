import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lugo_customer/page/otp/controller_otp.dart';
import 'package:lugo_customer/shared/widget/button.dart';
import 'package:lugo_customer/shared/widget/input.dart';
import 'package:validatorless/validatorless.dart';

class PageOtp extends GetView<ControllerOtp> {
  const PageOtp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: InkWell(
          onTap: () => Get.back(),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Text(
              "Masukan Nomor Telepon Veritifikasi Anda",
              style: GoogleFonts.readexPro(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF14181B),
              ),
            ),
          ),
          Form(
            key: controller.formkeyPhone,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Input(
                enabled: controller.editablePhoneNumber.value,
                controller: controller.edtPhone,
                keyboardType: TextInputType.phone,
                hintText: 'Nomor Telepon',
                labelText: 'Nomor Telepon',
                validator: Validatorless.multiple([
                  Validatorless.required('Ponsel tidak boleh kosong'),
                  Validatorless.min(10, 'Ponsel tidak boleh kurang dari 10'),
                ]),
              ),
            ),
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Button(
                  onPressed: () {
                    final okForm =
                        controller.formkeyPhone.currentState!.validate();
                    final isLoading = controller.loadingPhoneVerification.value;
                    if (okForm && !isLoading) {
                      controller.handleVerifyPhoneNumber();
                    }
                  },
                  child: controller.loadingPhoneVerification.value
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Lanjutkan",
                          style: GoogleFonts.readexPro(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
