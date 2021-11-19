import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login.dart';
import 'alarm.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title

      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Auth System",
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late SharedPreferences sharedPreferences;
  bool loading = true;
  WebViewController? _webViewController;
  final Completer<WebViewController> _controllerCompleter =
      Completer<WebViewController>();
  String id = '';
  String url = '';

  //Make sure this function return Future<bool> otherwise you will get an error

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
    super.initState();
    loginStatus();
  }

  loginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") != null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    } else {
      var duration = const Duration(seconds: 2);
      return Timer(
        duration,
        () {
          setState(() {
            loading = false;
            url = 'http://watchbook.tv/user/welcome';
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading == true) {
      return WillPopScope(
          onWillPop: () => _goBack(context),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
              height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .height,
              decoration: const BoxDecoration(
                image: const DecorationImage(
                  image: const AssetImage('images/default/background.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('images/login_logo.png', fit: BoxFit.cover),
                ],
              ),
            ),
          ));
    } else {
      return WillPopScope(
          onWillPop: () => _goBack(context),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: WebView(
                key: UniqueKey(),
                initialUrl: url,
                onWebViewCreated: (WebViewController webViewController) {
                  _controllerCompleter.future
                      .then((value) => _webViewController = value);
                  _controllerCompleter.complete(webViewController);
                },
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black),
              title: const Text("Watchbook",
                  style: TextStyle(color: Colors.black)),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      AlarmPage()))
                        },
                    icon: const Icon(
                      Icons.add_alert,
                      color: Colors.black,
                    ))
              ],
            ),
            drawer: Drawer(
                child: ListView(
              padding: EdgeInsets.zero, // 여백x
              children: [
                UserAccountsDrawerHeader(
                  accountName: const Text("유저이름"),
                  accountEmail: const Text("메일주소"),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('/images/login_logo.png'),
                  ),
                  onDetailsPressed: () => {print('click')},
                  decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40.0),
                          bottomRight: Radius.circular(40.0))),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.home,
                    color: Colors.grey,
                  ),
                  title: const Text('Home'),
                  onTap: () => {print("home")},
                  trailing: const Icon(Icons.add),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.home,
                    color: Colors.grey,
                  ),
                  title: const Text('Setting'),
                  onTap: () => {print("settting")},
                  trailing: const Icon(Icons.add),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.home,
                    color: Colors.grey,
                  ),
                  title: const Text('Q&A'),
                  onTap: () => {print("Q&A")},
                  trailing: const Icon(Icons.add),
                ),
              ],
            )),
          ));
    }
  }

  //뒤로가기 키 눌렀을시 뒤로가고 마지막 페이지에서 종료문구 뜨게 설정
  Future<bool> _goBack(BuildContext context) async {
    if (_webViewController == null) {
      return true;
    }
    if (await _webViewController!.canGoBack()) {
      _webViewController!.goBack();
      return Future.value(false);
    } else {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('와치북을 종료하시겠어요?'),
          actions: <Widget>[
            TextButton(
              child: const Text('네'),
              onPressed: () => Navigator.pop(context, true),
            ),
            TextButton(
              child: const Text('아니오'),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ).then((value) => value ?? false);
    }
  }
}
