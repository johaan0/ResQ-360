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
    apiKey: 'AIzaSyB6taLZCPkP1UfRuZZviQ5qKLyqZ2dl_Ps',
    appId: '1:541270939899:web:5a5c6a8a547532da36b85e',
    messagingSenderId: '541270939899',
    projectId: 'sample-app-618f9',
    authDomain: 'sample-app-618f9.firebaseapp.com',
    storageBucket: 'sample-app-618f9.firebasestorage.app',
    measurementId: 'G-RK5FWY4XL3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqEyylRw9b45xI7mG8ZqAwFHOKVzMI3oE',
    appId: '1:541270939899:android:e4fec75e68f40dd936b85e',
    messagingSenderId: '541270939899',
    projectId: 'sample-app-618f9',
    storageBucket: 'sample-app-618f9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCV5t7c_GmfUMXrfMQCtuFnv-WrxG2g9SY',
    appId: '1:541270939899:ios:517d0e92c69bbce036b85e',
    messagingSenderId: '541270939899',
    projectId: 'sample-app-618f9',
    storageBucket: 'sample-app-618f9.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCV5t7c_GmfUMXrfMQCtuFnv-WrxG2g9SY',
    appId: '1:541270939899:ios:517d0e92c69bbce036b85e',
    messagingSenderId: '541270939899',
    projectId: 'sample-app-618f9',
    storageBucket: 'sample-app-618f9.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB6taLZCPkP1UfRuZZviQ5qKLyqZ2dl_Ps',
    appId: '1:541270939899:web:f281f03e3d9f0a9336b85e',
    messagingSenderId: '541270939899',
    projectId: 'sample-app-618f9',
    authDomain: 'sample-app-618f9.firebaseapp.com',
    storageBucket: 'sample-app-618f9.firebasestorage.app',
    measurementId: 'G-03WDXLFP1V',
  );
}
