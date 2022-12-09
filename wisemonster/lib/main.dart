import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/binding/binding.dart';
import 'package:wisemonster/routes/app_pages.dart';
import 'package:wisemonster/view/camera_view.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/splash_view.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:wisemonster/models/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'api/api_services.dart';


ApiServices api = ApiServices();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
  print(message.data);

}
late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyC82k385JVg5-Dpcid3WRfF1JpdwH4viO0', // google-service.json 파일에 값 확인가능
            appId: '1:323332851667:android:d4f97d67d2f6b3c9981126',
            // 나머지 세개는 firebase console 페이지에서 확인가능
            messagingSenderId: '',
            projectId: 'wisemonster-27620')
    );

  await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    // foreground에서 알림 중요도 설정
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title

      importance: Importance.high,
    );

    var initialzationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    var initialzationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // foreground에서 알림 표시를 위한 local notifications 설정

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    var initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid, iOS: initialzationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,

      onSelectNotification: (String? payload) async {
        print(payload);
        print('포그라운드클릭');
        if (payload != null) {
          Get.to(camera_view());
        }
      },

    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      // save token to server
      sharedPreferences.setString('FCMtoken', newToken!);
    });
    String? token = await FirebaseMessaging.instance.getToken();

    print("token : ${token ?? 'token NULL!'}");

    sharedPreferences.setString('FCMtoken', token!);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      AndroidNotification? android = message.notification?.android;
      var androidNotiDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: '@mipmap/ic_launcher',
      );
      var iOSNotiDetails = const IOSNotificationDetails();
      var details =
      NotificationDetails(android: androidNotiDetails, iOS: iOSNotiDetails);
      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          message.notification.hashCode,
          message.notification?.title,
          message.notification?.body,
          details,
          payload:message.data['click_action']
        );
      }
      print('포그라운드');
      print(message.data);
      print(message.data['click_action']);


    });


    void _handleMessage(RemoteMessage message) {
      print('message = ${message.notification!.title}');
      Get.off(home_view());
    }

      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

      // 종료상태에서 클릭한 푸시 알림 메세지 핸들링
      if (initialMessage != null) _handleMessage(initialMessage);

      // 앱이 백그라운드 상태에서 푸시 알림 클릭 하여 열릴 경우 메세지 스트림을 통해 처리
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    initializeDateFormatting().then((_) =>
        runApp(
          Phoenix(
            child:GetMaterialApp(
              debugShowCheckedModeBanner: false,
              getPages: AppPages.routes,
              initialBinding: SplahBinding(),
              home: splash_view(),
            ) ,
          )
        )
  );
  }
}


