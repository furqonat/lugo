import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lugo_customer/response/chat.dart';
import 'package:lugo_customer/shared/controller/controller_user.dart';
import 'api_chat.dart';

class ControllerChat extends GetxController {
  final ApiChat api;
  ControllerChat({required this.api});

  var orderTransaksiId = ''.obs;
  var attachment = ''.obs;
  var showAttachment = false.obs;

  var edtChat = TextEditingController();

  var view = ''.obs;
  var upload = ''.obs;
  late XFile? file;

  ImagePicker picker = ImagePicker();

  ControllerUser controllerUser = Get.find<ControllerUser>();

  @override
  void dispose() {
    edtChat.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    orderTransaksiId.value = Get.arguments["orderTransaksiId"];
    super.onInit();
  }

  Stream<List<Chat>> getChat() {
    return FirebaseFirestore.instance
        .collection('chat')
        .where('chatFor', isEqualTo: 'CUSTOMER')
        .where('orderTransaksiId', isEqualTo: orderTransaksiId.value)
        .orderBy('time', descending: false)
        .snapshots()
        .map((event) => event.docs
            .map((e) {
              log("${e.data()}");
              return Chat.fromJson(e.data());
            })
            .toList()
            .reversed
            .toList());
  }

  sendChat() async {
    try {
      await api.sendChat(
          msg: edtChat.text,
          senderId: controllerUser.user.value.id!,
          chatFor: 'CUSTOMER',
          time: DateTime.now(),
          orderTransaksiId: orderTransaksiId.value,
          attachment: upload.value);
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
    }
  }

  pickImage(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text("Ambil gambar dari?",
            style: GoogleFonts.poppins(fontSize: 12)),
        actions: [
          OutlinedButton(
              onPressed: () {
                getFromCamera();
                Get.back();
              },
              child: Text("Camera", style: GoogleFonts.poppins(fontSize: 12))),
          OutlinedButton(
              onPressed: () {
                getFromFile();
                Get.back();
              },
              child: Text("Galeri", style: GoogleFonts.poppins(fontSize: 12)))
        ],
      ),
    );
  }

  getFromCamera() async {
    final XFile? camImage =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (camImage != null) {
      view.value = camImage.path;
      file = camImage;
      showAttachment(true);
      uploadImage();
    }
  }

  getFromFile() async {
    final XFile? fileImage =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (fileImage != null) {
      view.value = fileImage.path;
      file = fileImage;
      showAttachment(true);
      uploadImage();
    }
  }

  uploadImage() async {
    if (file == null) {
      log('Error: File is null.');
      return;
    }

    String fileName = file!.name;
    final path = 'chet/attachment/$fileName';
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      File fileToUpload = File(file!.path);

      UploadTask uploadTask = ref.putFile(fileToUpload);

      uploadTask.whenComplete(() async {
        String downloadURL = await ref.getDownloadURL();
        upload.value = downloadURL;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Foto gagal di unggah');
    }
  }
}
