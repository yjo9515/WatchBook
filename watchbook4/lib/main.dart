import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchbook4/routes/app_pages.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  // if (!kIsWeb) {
  //   channel = const AndroidNotificationChannel(
  //     'high_importance_channel', // id
  //     'High Importance Notifications', // title
  //
  //     importance: Importance.high,
  //   );
  //
  //   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //
  //   await flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //       AndroidFlutterLocalNotificationsPlugin>()
  //       ?.createNotificationChannel(channel);
  //
  //   await FirebaseMessaging.instance
  //       .setForegroundNotificationPresentationOptions(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  // }
  runApp(GetMaterialApp(home: MainPage()));
}

class MainPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      initialRoute: AppPages.INITIAL,
    );
  }

}

