// ⚠️  REPLACE THIS FILE — run the command below inside your project folder:
//
//   dart pub global run flutterfire_cli:flutterfire configure \
//     --project=campustrust-nkozi \
//     --platforms=android \
//     --android-package-name=com.umu.campustrust
//
// flutterfire will overwrite this file with your real credentials.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'CampusTrust is Android-only. '
          'Run flutterfire configure to regenerate this file.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4dtrKGswRVKQckU7HNZOxKwQv-rcw0kM',
    appId: '1:510285306261:android:53a97241950769ef3b7e9c',
    messagingSenderId: '510285306261',
    projectId: 'campustrust-umu-v3-1fb07',
    storageBucket: 'campustrust-umu-v3-1fb07.firebasestorage.app',
  );

}