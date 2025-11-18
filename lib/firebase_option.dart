// File generated manually for Firebase initialization in Flutter.
// Replace only if you update your Firebase project.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // -------------------------
  // 🌐 WEB CONFIG
  // -------------------------
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAGqaLZUnjyjxltFYuzSDe7JLKYuiCQzs8",
    authDomain: "podologia-68aa4.firebaseapp.com",
    projectId: "podologia-68aa4",
    storageBucket: "podologia-68aa4.firebasestorage.app",
    messagingSenderId: "409627415295",
    appId: "1:409627415295:web:3a8d649c793fc2f1ba72ca",
  );

  // -------------------------
  // 🤖 ANDROID CONFIG
  // -------------------------
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAcvMWEhubassrS-meDGWc_fi_75E7yjj0",
    appId: "1:409627415295:android:7426706f63908816ba72ca",
    messagingSenderId: "409627415295",
    projectId: "podologia-68aa4",
    storageBucket: "podologia-68aa4.firebasestorage.app",
  );

  // -------------------------
  // 🍏 iOS CONFIG (VACÍO PORQUE NO LO PASASTE)
  // -------------------------
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "",
    appId: "",
    messagingSenderId: "409627415295",
    projectId: "podologia-68aa4",
    storageBucket: "podologia-68aa4.firebasestorage.app",
  );

  // -------------------------
  // 🖥 Windows (Web-compatible)
  // -------------------------
  static const FirebaseOptions windows = web;

  // -------------------------
  // 🐧 Linux (Web-compatible)
  // -------------------------
  static const FirebaseOptions linux = web;

  // -------------------------
  // 🍎 macOS (Web-compatible)
  // -------------------------
  static const FirebaseOptions macos = web;
}
