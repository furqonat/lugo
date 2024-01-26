// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDilMOyvhtYIxKK2sBUXNx3xNSoIZajLV8',
    appId: '1:484579186038:web:04a290b57ad82b7f241657',
    messagingSenderId: '484579186038',
    projectId: 'lumajanglugo-c6269',
    authDomain: 'lumajanglugo-c6269.firebaseapp.com',
    storageBucket: 'lumajanglugo-c6269.appspot.com',
    measurementId: 'G-3HEEXDWB5H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsqiBE9DPIRakTYuDQttsxmt8o1P2Gv-Q',
    appId: '1:484579186038:android:4bee4fbaea04f076241657',
    messagingSenderId: '484579186038',
    projectId: 'lumajanglugo-c6269',
    storageBucket: 'lumajanglugo-c6269.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCmhutFMiWs35htsllf8nHuoW0JQlDf6AU',
    appId: '1:484579186038:ios:02e85df0033160c5241657',
    messagingSenderId: '484579186038',
    projectId: 'lumajanglugo-c6269',
    storageBucket: 'lumajanglugo-c6269.appspot.com',
    iosBundleId: 'com.gentatechnology.merchant',
  );
}
