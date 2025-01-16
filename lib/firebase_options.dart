// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyAgiO_L6y88fWEvyNGRfXynuTPJmaUO5n0',
    appId: '1:885501349437:web:a4a00f3e5bf6b8f8eb6454',
    messagingSenderId: '885501349437',
    projectId: 'eco-connect-a2aae',
    authDomain: 'eco-connect-a2aae.firebaseapp.com',
    storageBucket: 'eco-connect-a2aae.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC3d9RPKgHQEH0G1kef7e0WRN8EkpqdUWU',
    appId: '1:885501349437:android:8b2598730540dec4eb6454',
    messagingSenderId: '885501349437',
    projectId: 'eco-connect-a2aae',
    storageBucket: 'eco-connect-a2aae.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDLdMhKNAQWyutgbyX3Ob3PokJCZayLDx4',
    appId: '1:885501349437:ios:a7181c5ae55168b9eb6454',
    messagingSenderId: '885501349437',
    projectId: 'eco-connect-a2aae',
    storageBucket: 'eco-connect-a2aae.firebasestorage.app',
    iosBundleId: 'com.example.eccoconnect',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDLdMhKNAQWyutgbyX3Ob3PokJCZayLDx4',
    appId: '1:885501349437:ios:a7181c5ae55168b9eb6454',
    messagingSenderId: '885501349437',
    projectId: 'eco-connect-a2aae',
    storageBucket: 'eco-connect-a2aae.firebasestorage.app',
    iosBundleId: 'com.example.eccoconnect',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBjmcLNPhTn_hHJzgc0sRssvK5rApxcpT4',
    appId: '1:885501349437:web:fd0282e89c7864ddeb6454',
    messagingSenderId: '885501349437',
    projectId: 'eco-connect-a2aae',
    authDomain: 'eco-connect-a2aae.firebaseapp.com',
    storageBucket: 'eco-connect-a2aae.firebasestorage.app',
  );
}