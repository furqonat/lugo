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
    apiKey: 'AIzaSyAGikGJLIHMrl448HIeTR4LMrlGyyfrQ_k',
    appId: '1:212947611038:web:057024a2f40f6c1b2dba8f',
    messagingSenderId: '212947611038',
    projectId: 'lugo-9f0a6',
    authDomain: 'lugo-9f0a6.firebaseapp.com',
    databaseURL: 'https://lugo-9f0a6-default-rtdb.firebaseio.com',
    storageBucket: 'lugo-9f0a6.appspot.com',
    measurementId: 'G-JGEW8EZ9RL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZ8UOxeq9J00GFaSKS-7tSTKmHrfimt_U',
    appId: '1:212947611038:android:68e5c2df607828012dba8f',
    messagingSenderId: '212947611038',
    projectId: 'lugo-9f0a6',
    databaseURL: 'https://lugo-9f0a6-default-rtdb.firebaseio.com',
    storageBucket: 'lugo-9f0a6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCC-fDgTDZsltl9OGw_kOoY-qU5_fAqwjg',
    appId: '1:212947611038:ios:aa59fe23977d85d02dba8f',
    messagingSenderId: '212947611038',
    projectId: 'lugo-9f0a6',
    databaseURL: 'https://lugo-9f0a6-default-rtdb.firebaseio.com',
    storageBucket: 'lugo-9f0a6.appspot.com',
    androidClientId: '212947611038-398iun1nuk5ajs1lcrbgve8p11kom03r.apps.googleusercontent.com',
    iosBundleId: 'com.lugoapp.driver',
  );
}
