import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:lugo_customer/api/local_service.dart';
import 'package:lugo_customer/page/check_order/api_checkorder.dart';
import 'package:lugo_customer/response/driver.dart';
import 'package:lugo_customer/response/driver_profile.dart';
import 'package:lugo_customer/response/live_transaction.dart';
import 'package:lugo_customer/route/route_name.dart';

class ControllerCheckOrder extends GetxController {
  final ApiCheckOrder api;
  ControllerCheckOrder({required this.api});

  var requestType = ''.obs;
  var orderId = ''.obs;
  var cancelStatus = true.obs;
  var price = 0.obs;

  late BitmapDescriptor icon;

  final FirebaseAuth firebase = FirebaseAuth.instance;

  RxSet<Marker> markers = RxSet<Marker>();

  Rx<LocationData> myLocation = LocationData.fromMap({
    'latitude': 0.0,
    'longitude': 0.0,
  }).obs;

  Rx<LocationData> destinationLocation = LocationData.fromMap({
    'latitude': 0.0,
    'longitude': 0.0,
  }).obs;

  Rx<LocationData> driverLocation = LocationData.fromMap({
    'latitude': 0.0,
    'longitude': 0.0,
  }).obs;

  var driver = DriverProfile().obs;

  RxList<LatLng> rute = <LatLng>[].obs;

  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  PolylinePoints polylinePoints = PolylinePoints();

  final Completer<GoogleMapController> mapController = Completer();

  @override
  void onInit() {
    loadCustomIcon();
    requestType.value = Get.arguments["request_type"];
    myLocation.value = LocationData.fromMap({
      'latitude': Get.arguments['latitude'],
      'longitude': Get.arguments['longitude'],
    });
    destinationLocation.value = LocationData.fromMap({
      'latitude': Get.arguments['dstLatitude'],
      'longitude': Get.arguments['dstLongitude'],
    });
    orderId.value = Get.arguments["order_id"];
    price.value = Get.arguments['price'];

    markers.add(Marker(
        markerId: const MarkerId("Saya"),
        position:
            LatLng(myLocation.value.latitude!, myLocation.value.longitude!)));
    if (requestType.value != 'FOOD' || requestType.value != 'MART') {
      findDriver();
    }

    super.onInit();
  }

  void loadCustomIcon() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/marker_bike.png', 50);
    customIcon = BitmapDescriptor.fromBytes(markerIcon);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec =
        await ui.instantiateImageCodec(Uint8List.view(data.buffer));
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  setRoutes(var startLatitude, var startLongitude, var dstLatitude,
      var dstLongitude) async {
    try {
      rute.clear();

      var start = PointLatLng(startLatitude, startLongitude);

      var route = await polylinePoints.getRouteBetweenCoordinates(
          'AIzaSyD2iESGIyoYaZVPffaXa42wmVp2NxKACcM',
          start,
          PointLatLng(dstLatitude, dstLongitude));

      if (route.errorMessage != null) {
        if (route.points.isNotEmpty) {
          for (var i in route.points) {
            rute.add(LatLng(i.latitude, i.longitude));
          }
        }
      } else {
        log('error => ${route.errorMessage}');
      }
    } catch (e) {
      log('error => $e');
    }
  }

  initialLocation(var latitude, var longitude) async {
    GoogleMapController googleMapController = await mapController.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(zoom: 17, target: LatLng(latitude, longitude))));
  }

  findDriver() async {
    try {
      var token = await firebase.currentUser?.getIdToken();
      await api.findDriver(
          latitude: myLocation.value.latitude!,
          longitude: myLocation.value.longitude!,
          orderId: orderId.value,
          token: token!);
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
    }
  }

  findDriverDetail(String id) async {
    try {
      var token = await firebase.currentUser?.getIdToken();
      var r = await api.getDriver(driverId: id, token: token!);
      driver.value = DriverProfile.fromJson(r);
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
    }
  }

  Stream<LiveTransaction?>? trackTransaction() =>
      api.getOrder<LiveTransaction?>(
          documentId: orderId.value,
          fromJson: (data) => LiveTransaction.fromJson(data));

  Stream<List<Driver>>? listenLocation(String id) {
    return FirebaseFirestore.instance
        .collection('drivers')
        .where('id', isEqualTo: id)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => Driver.fromJson(e.data())).toList());
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
                                )),
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

  cancelOrder() async {
    try {
      var token = await firebase.currentUser?.getIdToken();
      var r = await api.cancelOrder(orderId: orderId.value, token: token!);
      if (r["message"] == "Success") {
        await LocalService().orderFinish();
        WidgetsBinding.instance
            .addPostFrameCallback((_) => Get.offNamed(Routes.home));
      }
    } catch (e, stackTrace) {
      log('$e');
      log('$stackTrace');
    }
  }
}
