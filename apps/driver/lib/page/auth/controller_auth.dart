import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lugo_driver/shared/preferences.dart';
import 'package:rest_client/auth_client.dart';

import '../../route/route_name.dart';

class ControllerAuth extends GetxController
    with GetSingleTickerProviderStateMixin {
  ControllerAuth({
    required this.authClient,
    required this.preferences,
  });

  final AuthClient authClient;
  final Preferences preferences;

  late TabController tabController;

  final _fbAuth = FirebaseAuth.instance;

  final signInForm = GlobalKey<FormState>();
  final signUpForm = GlobalKey<FormState>();

  final emailSignIn = TextEditingController();
  final passwordSignIn = TextEditingController();
  final emailSignUp = TextEditingController();
  final passwordSignUp = TextEditingController();
  final referal = TextEditingController();

  final showPass = true.obs;

  final partnerList = [
    "Bergabung sebagai?",
    "BIKE",
    "CAR",
  ].obs;

  var partnerType = "Bergabung sebagai?".obs;

  handlSignIn() async {
    final isValid = signInForm.currentState!.validate();
    if (!isValid) {
      Fluttertoast.showToast(msg: "unable to verification");
      return;
    }
    try {
      final credential = await _fbAuth.signInWithEmailAndPassword(
        email: emailSignIn.value.text,
        password: passwordSignIn.value.text,
      );
      final token = await credential.user?.getIdToken();
      final resp = await authClient.driverSignIn("Bearer $token");
      if (resp.message == 'OK') {
        preferences.setAlreadySignIn(true);
        preferences.setPatnerType(partnerType.value);
        Get.toNamed(Routes.phoneVerification);
      } else {
        Get.snackbar('Error', resp.message);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'Wrong password provided for that user.');
      }
    }
  }

  handleSignUp() async {
    final formState = signUpForm.currentState!.validate();
    final isValidPatner = partnerType.value != "Bergabung sebagai?";
    if (formState && isValidPatner) {
      try {
        final credential = await _fbAuth.createUserWithEmailAndPassword(
          email: emailSignUp.text,
          password: passwordSignUp.text,
        );
        final token = await credential.user?.getIdToken(true);
        // print(token);
        final resp = await authClient.driverSignIn("Bearer $token");
        if (resp.message == 'OK') {
          preferences.setPatnerType(partnerType.value);
          preferences.setReferal(referal.text);
          preferences.setAlreadySignIn(true);
          Get.toNamed(Routes.phoneVerification);
        } else {
          Fluttertoast.showToast(msg: resp.message);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(msg: 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          Fluttertoast.showToast(msg: 'Wrong password provided for that user.');
        }
      }
    } else {
      Fluttertoast.showToast(msg: "please fill empty form");
    }
  }

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }

  @override
  void dispose() {
    emailSignIn.dispose();
    passwordSignIn.dispose();
    referal.dispose();
    super.dispose();
  }
}
