import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions have not been configured for web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;

      default:
        throw UnsupportedError(
          'FirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDOHH52qsz0cIEePyeNfNuF6SRJFozrInM',
    appId: '1:341547368699:android:c2c463aaae3038ee96f05e',
    messagingSenderId: '341547368699',
    projectId: 'roporchat',
    databaseURL: 'https://roporchat-default-rtdb.firebaseio.com',
    storageBucket: 'roporchat.firebasestorage.app',
  );
}
