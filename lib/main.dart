import 'package:flutter/material.dart';
import 'package:manga_reader/pages/extra/statistics_page.dart';
import 'package:manga_reader/pages/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:manga_reader/utils/database.dart';
import 'package:sqflite/sqflite.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // print('User granted permission: ${settings.authorizationStatus}');

  DatabaseUtil.dbPath = await getDatabasesPath();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        StatisticsPage.routeName: (context) => const StatisticsPage(),
        '/': (context) => const MainPage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Manga',
      theme: ThemeData(
          colorScheme: const ColorScheme.dark(tertiary: Colors.pinkAccent),
          textTheme: const TextTheme(
            // headline5: TextStyle(),
            subtitle2: TextStyle(color: Colors.grey),
            bodyText1: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          )),
    );
  }
}
