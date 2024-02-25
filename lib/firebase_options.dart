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
        return macos;
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
    apiKey: 'AIzaSyB2aeYtp0YqDpPEF0gJofUM21xVnTTNsw0',
    appId: '1:12346867776:web:c924f381f9c9bcbd2ddfa5',
    messagingSenderId: '12346867776',
    projectId: 'cal-time-tracker',
    authDomain: 'cal-time-tracker.firebaseapp.com',
    storageBucket: 'cal-time-tracker.appspot.com',
    measurementId: 'G-3HZK4JLVPM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSWoSUf6OiceqPv1JYQGG_UNTTTXMdhAg',
    appId: '1:12346867776:android:b5485d5be102791a2ddfa5',
    messagingSenderId: '12346867776',
    projectId: 'cal-time-tracker',
    storageBucket: 'cal-time-tracker.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqW_Clq5Tm6StCTuA-LPBcewmXowTSrEQ',
    appId: '1:12346867776:ios:01d83f862617017f2ddfa5',
    messagingSenderId: '12346867776',
    projectId: 'cal-time-tracker',
    storageBucket: 'cal-time-tracker.appspot.com',
    iosClientId: '12346867776-3dpu82pit9i0d3lnurhoq319pir7kier.apps.googleusercontent.com',
    iosBundleId: 'com.example.calTimeTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAqW_Clq5Tm6StCTuA-LPBcewmXowTSrEQ',
    appId: '1:12346867776:ios:f7430f609dbdb5462ddfa5',
    messagingSenderId: '12346867776',
    projectId: 'cal-time-tracker',
    storageBucket: 'cal-time-tracker.appspot.com',
    iosClientId: '12346867776-ftrnq09a5itcbqfr75g77p2nju09nd0o.apps.googleusercontent.com',
    iosBundleId: 'com.example.calTimeTracker.RunnerTests',
  );
}
