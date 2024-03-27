import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lugo_customer/page/edit_profile/controller_editprofile.dart';
import 'package:validatorless/validatorless.dart';

class PageEditProfile extends GetView<ControllerEditProfile> {
  const PageEditProfile({super.key});

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
                  controller.imgPreview.value == ''
                      ? CachedNetworkImage(
                          width: Get.width,
                          height: Get.height * 0.3,
                          fit: BoxFit.cover,
                          imageUrl: controller.photoProfile.value,
                          errorWidget: (context, url, error) => Image(
                              width: Get.width,
                              height: Get.height * 0.3,
                              fit: BoxFit.cover,
                              image:
                                  const AssetImage('assets/images/person.png')),
                        )
                      : Image.file(
                          width: Get.width,
                          height: Get.height * 0.3,
                          fit: BoxFit.cover,
                          File(controller.imgPreview.value)),
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
                        ElevatedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog.adaptive(
                              content: Text(
                                'Anda ingin mengambil gambar dari mana?',
                                style: GoogleFonts.readexPro(),
                              ),
                              actions: [
                                OutlinedButton(
                                    onPressed: () {
                                      controller.getFromFile();
                                      Get.back();
                                    },
                                    child: Text(
                                      'Gallery',
                                      style: GoogleFonts.readexPro(),
                                    )),
                                OutlinedButton(
                                    onPressed: () {
                                      controller.getFromCamera();
                                      Get.back();
                                    },
                                    child: Text(
                                      'Camera',
                                      style: GoogleFonts.readexPro(),
                                    )),
                              ],
                            ),
                          ),
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
                            "Edit Photo",
                            style: GoogleFonts.readexPro(
                                fontSize: 12, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: controller.formkeyEditUser,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextFormField(
                    autofocus: false,
                    controller: controller.edtName,
                    style: GoogleFonts.readexPro(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: GoogleFonts.readexPro(
                        fontSize: 12,
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
                    ),
                    validator:
                        Validatorless.required('Nama tidak boleh kosong'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.phone,
                    controller: controller.edtPhone,
                    style: GoogleFonts.readexPro(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nomor Telepon',
                      hintStyle: GoogleFonts.readexPro(
                        fontSize: 12,
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
                    ),
                    validator: Validatorless.multiple([
                      Validatorless.required('Ponsel tidak boleh kosong'),
                      Validatorless.regex(RegExp(r'^[1-9][0-9]{8,}$'),
                          'Ponsel tidak sesuai, cukup gunakan 813xxxxxxxx'),
                    ]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextFormField(
                      autofocus: false,
                      keyboardType: TextInputType.emailAddress,
                      controller: controller.edtEmail,
                      style: GoogleFonts.readexPro(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: GoogleFonts.readexPro(
                          fontSize: 12,
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
                      ),
                      validator: Validatorless.multiple([
                        Validatorless.required('Email tidak boleh kosong'),
                        Validatorless.email('Format email tidak benar')
                      ])),
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: ElevatedButton(
                      onPressed: () {
                        if (controller.formkeyEditUser.currentState!
                            .validate()) {
                          if (controller.phoneCheck.value ==
                              controller.edtPhone.text) {
                            controller.updateUser();
                          } else {
                            controller.firebasePhoneVerification(context);
                          }
                        }
                        // controller.uploadImage();
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          fixedSize: Size(Get.width, Get.height * 0.05),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: const Color(0xFF3978EF)),
                      child: Text(
                        "Simpan",
                        style: GoogleFonts.readexPro(
                            fontSize: 14, color: Colors.white),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
