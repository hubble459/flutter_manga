// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    // ignore: missing_enum_constant_in_switch
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
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9i8ucP4kMCDL99jUdqDulZ311kTVn_f4',
    appId: '1:1011698401606:android:5e1a34e07410cf0291a547',
    messagingSenderId: '1011698401606',
    projectId: 'manga-reader-5c535',
    storageBucket: 'manga-reader-5c535.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCZsjggZnh14vAreK7ScEHbC2KJVl-2P7k',
    appId: '1:1011698401606:ios:3efe5c94b031607191a547',
    messagingSenderId: '1011698401606',
    projectId: 'manga-reader-5c535',
    storageBucket: 'manga-reader-5c535.appspot.com',
    iosClientId: '1011698401606-q42b60qhrf72oup9emvpdo9qjuhdg5es.apps.googleusercontent.com',
    iosBundleId: 'nl.hubble.mangareader',
  );
}
