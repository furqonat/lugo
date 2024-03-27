import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lugo_marchant/api/local_service.dart';
import 'package:lugo_marchant/page/verification/phone_verification.dart';
import 'package:lugo_marchant/route/route_name.dart';
import 'package:phone_number/phone_number.dart';

import 'api.dart';

enum VerificationState {
  phoneOnly,
  full,
}

enum UploadStatus {
  idle,
  uploading,
}

enum ImageType {
  idCard,
  shopImage1,
  shopImage2,
}

class PhoneVerificationStatus {
  final bool status;
  final String message;

  PhoneVerificationStatus({required this.status, required this.message});
}

class VerificationController extends GetxController {
  VerificationController({required this.apiService});
  final ApiService apiService;
  final formPhoneVerification = GlobalKey<FormState>();

  // verification phone number
  final phoneNumber = TextEditingController();
  final smsCode = TextEditingController();

  // verification details
  final fullName = TextEditingController();
  final shopName = TextEditingController();
  final address = TextEditingController();
  final idCardImage = ''.obs;
  final shopImages1 = ''.obs;
  final shopImages2 = ''.obs;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;

  final imagePicker = ImagePicker();
  final uploadStatus = UploadStatus.idle.obs;

  final verificationState = Get.parameters['state'];
  final activeStep = 0.obs;
  final verificationStatus =
      PhoneVerificationStatus(status: false, message: "").obs;
  final loadingVerification = false.obs;
  final loadingPhoneVerification = false.obs;
  final isSuccesVerification = false.obs;

  final _fbAuth = FirebaseAuth.instance;
  final verificationId = "".obs;

  void handleActiveStep(int index) {
    activeStep.value = index;
  }

  void handleCaptureIdCardImage() async {
    final cameraImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    uploadImage(cameraImage, ImageType.idCard);
  }

  void handlePickShopImage1() async {
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    uploadImage(image, ImageType.shopImage1);
  }

  void handlePickShopImage2() async {
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    uploadImage(image, ImageType.shopImage2);
  }

  uploadImage(XFile? file, ImageType imageType) async {
    uploadStatus.value = UploadStatus.uploading;
    if (file == null) {
      Fluttertoast.showToast(msg: "No image are capture");
      uploadStatus.value = UploadStatus.idle;
      return;
    }
    String fileName = file.name;
    String cloudPath = "/verification/merchant/$fileName";
    Reference cloudRef = FirebaseStorage.instance.ref().child(cloudPath);
    File currentFile = File(file.path);
    UploadTask uploadTask = cloudRef.putFile(currentFile);
    uploadTask.whenComplete(() async {
      uploadStatus.value = UploadStatus.idle;
      String downloadUrl = await cloudRef.getDownloadURL();
      if (imageType == ImageType.idCard) {
        idCardImage.value = downloadUrl;
      }
      if (imageType == ImageType.shopImage1) {
        shopImages1.value = downloadUrl;
      }
      if (imageType == ImageType.shopImage2) {
        shopImages2.value = downloadUrl;
      }
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void pickAddress() async {
    _determinePosition().then((value) async {
      latitude.value = value.latitude;
      longitude.value = value.longitude;
      final places = await placemarkFromCoordinates(
        value.latitude,
        value.longitude,
      );
      final place = places.first;
      address.value = TextEditingValue(
        text:
            "${place.subLocality}, ${place.street}, ${place.name}, ${place.postalCode}",
      );
    }).catchError((error) {
      AppSettings.openAppSettings(type: AppSettingsType.location);
    });
  }

  void handleSaveDetail() async {
    loadingVerification.value = true;
    if (fullName.text.isEmpty || address.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all field");
      loadingVerification.value = false;
      return;
    }
    if (shopImages1.value.isEmpty || shopImages2.value.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all field");
      loadingVerification.value = false;
      return;
    }
    final body = {
      "name": fullName.value.text,
      "phone": _fbAuth.currentUser?.phoneNumber,
      "details": {
        "create": {
          "id_card_image": idCardImage.value,
          "address": address.value.text,
          "latitude": latitude.value,
          "longitude": longitude.value,
          "name": shopName.value.text,
          "images": {
            "createMany": {
              "data": [
                {"link": shopImages1.value},
                {"link": shopImages2.value}
              ]
            }
          }
        }
      }
    };
    final token = await _fbAuth.currentUser?.getIdToken(true);
    final result = await apiService.applyMerchant(body: body, token: token);
    if (result.message == 'OK') {
      loadingVerification.value = false;
      LocalService().setIsLogin(isLogin: true);
      LocalService().setInVerification(false);
      Get.offAllNamed(Routes.bottomNav);
    } else {
      loadingVerification.value = false;
      Fluttertoast.showToast(msg: "unable apply merchant");
    }
  }

  Future<void> handleVerificationPhone(
    Function(String verificationId) callback,
  ) async {
    loadingPhoneVerification.value = true;
    const regionInfo = RegionInfo(name: "Indonesia", code: "ID", prefix: 62);
    final phone = await PhoneNumberUtil().parse(
      phoneNumber.text,
      regionCode: regionInfo.code,
    );
    // final token = await _fbAuth.currentUser?.getIdToken();
    _fbAuth.verifyPhoneNumber(
      phoneNumber: phone.e164,
      verificationCompleted: (credential) {},
      verificationFailed: (error) {
        loadingPhoneVerification.value = false;
        verificationStatus.value = PhoneVerificationStatus(
          status: false,
          message: error.code,
        );
      },
      codeSent: (verf, forceResendingToken) {
        callback(verf);
        verificationStatus.value = PhoneVerificationStatus(
          status: true,
          message: "OK",
        );
        verificationId.value = verf;
        loadingPhoneVerification.value = false;
        bottomSheet(this);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
      timeout: const Duration(seconds: 60),
    );
    // final resp =
    //     await apiService.verifyPhone(phoneNumber: phone.e164, token: token!);
    // if (resp.message == 'OK') {
    //   verificationStatus.value = PhoneVerificationStatus(
    //     status: true,
    //     message: resp.message,
    //   );
    //   verificationId.value = resp.res;
    //   callback(resp.res);
    //   loadingPhoneVerification.value = false;
    //   return;
    // } else {
    //   loadingPhoneVerification.value = false;
    //   verificationStatus.value = PhoneVerificationStatus(
    //     status: false,
    //     message: resp.message,
    //   );
    //   Get.snackbar("Error", resp.message);
    //   return;
    // }
  }

  Future handleContinueVerification(
    String smsCode,
    String verificationId,
  ) async {
    const regionInfo = RegionInfo(name: "Indonesia", code: "ID", prefix: 62);
    final phone = await PhoneNumberUtil().parse(
      phoneNumber.text,
      regionCode: regionInfo.code,
    );

    // final token = await _fbAuth.currentUser?.getIdToken();
    final currentPhoneNumber = _fbAuth.currentUser?.phoneNumber;
    // final resp = await apiService.verifyOTP(
    //   token: token!,
    //   otp: smsCode,
    //   verificationId: verificationId,
    // );
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    if (currentPhoneNumber != null && currentPhoneNumber == phone.e164) {
      _fbAuth.currentUser
          ?.reauthenticateWithCredential(credential)
          .then((value) {
        if (verificationState == VerificationState.full.toString()) {
          verificationStatus.value = PhoneVerificationStatus(
            status: true,
            message: "OK",
          );
          activeStep.value = 1;
        } else {
          LocalService().setIsLogin(isLogin: true);
          LocalService().setInVerification(false);
          LocalService().setInVerificationStep(VerificationState.phoneOnly);
          Get.offAllNamed(Routes.bottomNav);
        }
      }).catchError((error) {
        verificationStatus.value = PhoneVerificationStatus(
          status: false,
          message: error.toString(),
        );
        Get.snackbar("Error", error.toString());
      });
    } else {
      _fbAuth.currentUser?.linkWithCredential(credential).then((value) {
        if (verificationState == VerificationState.full.toString()) {
          verificationStatus.value = PhoneVerificationStatus(
            status: true,
            message: "OK",
          );
          activeStep.value = 1;
        } else {
          LocalService().setIsLogin(isLogin: true);
          LocalService().setInVerification(false);
          LocalService().setInVerificationStep(VerificationState.phoneOnly);
          Get.offAllNamed(Routes.bottomNav);
        }
      }).onError((error, stackTrace) {
        verificationStatus.value = PhoneVerificationStatus(
          status: false,
          message: error.toString(),
        );
        Get.snackbar("Error", error.toString());
      });
    }
    // if (resp.message == 'OK') {
    //   if (verificationState == VerificationState.full.toString()) {
    //     verificationStatus.value = PhoneVerificationStatus(
    //       status: true,
    //       message: "OK",
    //     );
    //     activeStep.value = 1;
    //   } else {
    //     LocalService().setIsLogin(isLogin: true);
    //     LocalService().setInVerification(false);
    //     LocalService().setInVerificationStep(VerificationState.phoneOnly);
    //     Get.offAllNamed(Routes.bottomNav);
    //   }
    //   return;
    // } else {
    //   verificationStatus.value = PhoneVerificationStatus(
    //     status: false,
    //     message: resp.message,
    //   );
    //   Get.snackbar("Error", resp.message);
    // }
  }

  @override
  void onInit() {
    final phone = _fbAuth.currentUser?.phoneNumber;
    if (phone != null) {
      phoneNumber.value = TextEditingValue(text: phone.replaceAll(r'+62', ''));
    }
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _determinePosition().then((value) async {
      latitude.value = value.latitude;
      longitude.value = value.longitude;
      final places = await placemarkFromCoordinates(
        value.latitude,
        value.longitude,
      );
      final place = places.first;
      address.value = TextEditingValue(
        text:
            "${place.subLocality}, ${place.street}, ${place.name}, ${place.postalCode}",
      );
    }).catchError((error) {
      AppSettings.openAppSettings(type: AppSettingsType.location);
    });
  }
}
