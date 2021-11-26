import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login.dart';
import 'alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

// 저장소권한요청
Future<bool> _getStatuses(BuildContext context) async {
  Map<Permission, PermissionStatus> statuses =
      await [Permission.storage].request();
  if (await Permission.storage.isGranted == true) {
    print('저장소 권한 동의');
    return Future.value(true);
  } else {
    print('저장소 권한 비동의');
    return Future.value(false);
  }
}

Future<bool> _checkStoarge() async {
  bool status = await Permission.storage.isGranted;
  print('저장소 체크값 : ${status}');
  if (status == true) {
    return Future.value(true);
  } else {
    return Future.value(false);
  }
}

Future<bool> _checkNotification() async {
  bool status = await Permission.notification.isGranted;
  print('알람 체크값 : ${status}');
  if (status == true) {
    return Future.value(true);
  } else {
    return Future.value(false);
  }
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
    super.initState();
    _checkStoarge().then((value) async => {
          if (value == false)
            {_getStatuses(context)}
          else
            {
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
              }),
              FirebaseMessaging.onMessageOpenedApp
                  .listen((RemoteMessage message) {
                print('A new onMessageOpenedApp event was published!');
              })
            }
        });

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
                    onPressed: () async {
                      if (await _checkNotification() == true) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    AlarmPage()));
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const Text("권한 설정을 확인해주세요."),
                                actions: [
                                  FlatButton(
                                      onPressed: () {
                                        openAppSettings(); // 앱 설정으로 이동
                                      },
                                      child: const Text('설정하기')),
                                ],
                              );
                            });
                      }
                    },
                    icon: const Icon(
                      Icons.add_alert,
                      color: Colors.black,
                    ))
              ],
            ),
            drawer: Drawer(
              child: ListView(
                //메모리 문제해결
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                padding: EdgeInsets.zero, // 여백x
                children: [
                        Container(
                          height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                              .size
                              .height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                children: [
                                  Container(
                                    height: 120,
                                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 217, 84, 84),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          width: 252,
                                          height: 120,
                                          top: 10,
                                          child: UserAccountsDrawerHeader(
                                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                            decoration: const BoxDecoration(
                                              color: Color.fromARGB(255, 217, 84, 84),
                                            ),
                                            // keep blank text because email is required
                                            accountName: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 120,
                                                  height: 120,
                                                  decoration:
                                                  const BoxDecoration(
                                                    color: Colors.orange,
                                                  shape:BoxShape.circle,
                                                  )
                                                ),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    const Text('박보영님'),
                                                    const Text('LV.1'),
                                                    const Text('30C'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            accountEmail: Container(
                                              height: 0,
                                              width: 100,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () {
                                                print('d');
                                              },
                                              child: const Text(
                                                '내 정보',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 14,
                                            color: const Color.fromARGB(255, 207, 207, 207),
                                          ),
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () {
                                                print('d');
                                              },
                                              child: const Text(
                                                '스토어',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                  const Divider(color: Color.fromARGB(255, 207, 207, 207)),
                                  ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      IconData(62268, fontFamily: 'MaterialIcons'),
                                      color: const Color.fromARGB(255, 0, 104, 166),
                                    ),
                                    title: const Text('강좌',
                                        style: TextStyle(
                                            color: const Color.fromARGB(255, 0, 104, 166),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    onTap: () => {print("")},
                                    trailing: const Icon(
                                      IconData(61068,
                                          fontFamily: 'MaterialIcons', matchTextDirection: true),
                                      color: const Color.fromARGB(255, 0, 104, 166),
                                    ),
                                  ),
                                  const Divider(
                                      indent: 20,
                                      endIndent: 20,
                                      color: Color.fromARGB(255, 207, 207, 207)),
                                  ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      Icons.edit,
                                      color: const Color.fromARGB(255, 0, 104, 166),
                                    ),
                                    title: const Text('모의고사',
                                        style: TextStyle(
                                            color: const Color.fromARGB(255, 0, 104, 166),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    onTap: () => {print("settting")},
                                    trailing: const Icon(
                                      IconData(61068,
                                          fontFamily: 'MaterialIcons', matchTextDirection: true),
                                      color: const Color.fromARGB(255, 0, 104, 166),
                                    ),
                                  ),
                                  const Divider(
                                      indent: 20,
                                      endIndent: 20,
                                      color: Color.fromARGB(255, 207, 207, 207)),
                                  ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      IconData(0xeeb8, fontFamily: 'MaterialIcons'),
                                      color: const Color.fromARGB(255, 0, 104, 166),
                                    ),
                                    title: const Text('자격증',
                                        style: TextStyle(
                                            color: const Color.fromARGB(255, 0, 104, 166),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    onTap: () => {print("Q&A")},
                                    trailing: const Icon(
                                        IconData(61068,
                                            fontFamily: 'MaterialIcons',
                                            matchTextDirection: true),
                                        color: const Color.fromARGB(255, 0, 104, 166)),
                                  ),
                                  const Divider(
                                      indent: 20,
                                      endIndent: 20,
                                      color: Color.fromARGB(255, 207, 207, 207)),
                                  ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      IconData(58173, fontFamily: 'MaterialIcons'),
                                      color: const Color.fromARGB(255, 0, 104, 166),
                                    ),
                                    title: const Text('고객센터',
                                        style: TextStyle(
                                            color: const Color.fromARGB(255, 0, 104, 166),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    onTap: () => {print("Q&A")},
                                    trailing: const Icon(
                                        IconData(61068,
                                            fontFamily: 'MaterialIcons',
                                            matchTextDirection: true),
                                        color: const Color.fromARGB(255, 0, 104, 166)),
                                  ),
                                  const Divider(
                                      indent: 20,
                                      endIndent: 20,
                                      color: Color.fromARGB(255, 207, 207, 207)),
                                  ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      Icons.help_outline,
                                      color: const Color.fromARGB(255, 0, 104, 166),
                                    ),
                                    title: const Text('도움말',
                                        style: TextStyle(
                                            color: const Color.fromARGB(255, 0, 104, 166),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    onTap: () => {print("Q&A")},
                                    trailing: const Icon(
                                        IconData(61068,
                                            fontFamily: 'MaterialIcons',
                                            matchTextDirection: true),
                                        color: const Color.fromARGB(255, 0, 104, 166)),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(width:1,color: Color.fromARGB(
                                        255, 207, 207, 207), )
                                  )
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child:  const Text(
                                              '이용약관',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                            onPressed: () {
                                            },
                                          ),
                                          Container(
                                            width: 1,
                                            height: 14,
                                            color: Colors.black,
                                          ),
                                          TextButton(
                                            child:  const Text(
                                              '개인정보처리방침',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                            onPressed: () {

                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      child:  const Text(
                                        '로그아웃',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 0, 36, 98),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      onPressed: () {
                                      },
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )

                          ],
                        ),

              ),
            )
          );
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
