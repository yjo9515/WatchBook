import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'alarm.dart';
import 'index.dart';

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

Future<void> _kakaoLoginButtonPressed() async {
  final clientState = const Uuid().v4();
  final url = Uri.https('kauth.kakao.com', '/oauth/authorize', {
    'response_type': 'code',
    'client_id': '66bae9d5fcdbfb877a8a74edabc18f7a',
    'redirect_uri': 'https://www.watchbook.tv/oauth/kakao',
    'state': clientState,
  });
  final result = await FlutterWebAuth.authenticate(
      url: url.toString(), callbackUrlScheme: "webauthcallback");

  final body = Uri.parse(result).queryParameters;
  print(body);
}

Future<void> _naverLoginButtonPressed() async {
  final clientState = const Uuid().v4();
  final authUri = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
    'response_type': 'code',
    'client_id': 'C_TAVu2tex3Yjadne2IQ',
    'response_mode': 'form_post',
    'redirect_uri': 'https://www.watchbook.tv/oauth/naver',
    'state': clientState,
  });
  final authResponse = await FlutterWebAuth.authenticate(
      url: authUri.toString(), callbackUrlScheme: "webauthcallback");
  final code = Uri.parse(authResponse).queryParameters['code'];
  final tokenUri = Uri.https('nid.naver.com', '/oauth2.0/token', {
    'grant_type': 'authorization_code',
    'client_id': 'C_TAVu2tex3Yjadne2IQ',
    'client_secret': 'Z3ymBZN2Rd',
    'code': code,
    'state': clientState,
  });
  var tokenResult = await http.post(tokenUri);
  final accessToken = json.decode(tokenResult.body)['access_token'];
  final response = await http.get(Uri.parse(
      'https://www.watchbook.tv/oauth/naver/token?accessToken=$accessToken'));
}

Future<void> _facebookLoginButtonPressed() async {
  final LoginResult result = await FacebookAuth.instance
      .login(); // by default we request the email and the public profile
// or FacebookAuth.i.login()
  if (result.status == LoginStatus.success) {
    // you are logged
    final AccessToken accessToken = result.accessToken!;
  } else {
    print(result.status);
    print(result.message);
  }
}

class _MainPageState extends State<MainPage> {
  bool loading = true;
  late String errormsg;
  late bool error, showprogress;
  late String id, passwd;
  bool _isObscure = true;
  bool _isKakaoTalkInstalled = false;

  TextEditingController _id = TextEditingController();
  TextEditingController _passwd = TextEditingController();

  startLogin() async {
    String apiurl = 'https://www.watchbook.tv/User/getToken'; //api url
    print(id);

    var response = await http.post(Uri.parse(apiurl), body: {
      'id': _id.text, //get the id text
      'passwd': _passwd.text //get passwd text
    });

    if (response.statusCode == 200) {
      //정상신호 일때
      print('정상신호');
      print(response.body);
      var jsondata = json.decode(response.body);
      print(jsondata);
       if (jsondata["result"] == false) {
        setState(() {
          error = true;

        });
         print('d');
       } else {
         print('d2');
         if (jsondata["result"]) {
          setState(() {
            error = false;
          });
      //     //save the data returned from server
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => IndexPage()),
                  (Route<dynamic> route) => false
          );
      //     //and navigate to home page
      //     String id = jsondata["token"];
      //     print(id);
      //     //user shared preference to save data
      //   } else {
      //     showprogress = false; //don't show progress indicator
      //     error = true;
      //     errormsg = "Something went wrong.";
         }
       }
    } else {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Error during connecting to server.";
      });
    }
  }
  //Make sure this function return Future<bool> otherwise you will get an error

  @override
  void initState() {
    id = "";
    passwd = "";
    errormsg = "";
    error = false;
    showprogress = false;
    KakaoContext.clientId = 'e705415345f23aab069be7b7e95e9826';
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
  loginStatus() async{
    var duration = const Duration(seconds: 2);
    return Timer(
      duration,
          () {
        setState(() {
          loading = false;
        });
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    if (loading == true) {
      //스플래시 화면
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
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(statusBarColor: Colors.transparent
            //color set to transperent or set your own color
          ));
      return WillPopScope(
          onWillPop: () => _goBack(context),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: InkWell(
                onTap: () => _isKakaoTalkInstalled,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                  constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height
                    //set minimum height equal to 100% of VH
                  ),
                  width:
                  MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                      .size
                      .width,

                  //make width of outer wrapper to 100%
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/default/background.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  //show linear gradient background of page
                  child: Form(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 210,
                                height: 34,
                                alignment: Alignment.centerLeft,
                                margin: const EdgeInsets.fromLTRB(0, 0, 110, 0),
                                child: Image.asset(
                                  'images/login_logo.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.centerLeft,
                                ) //title text
                            ),
                            Container(
                              //show error message here
                              padding: const EdgeInsets.all(10),
                              child: error ? errmsg(errormsg) : Container(),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              width: 320,
                              child: Row(
                                children: <Widget>[
                                  const Expanded(
                                      child: Text('아이디',
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 16))),
                                  Expanded(
                                      flex: 2,
                                      child: TextField(
                                          controller: _id, //set id controller
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 16),
                                          decoration: const InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide:
                                                BorderSide(color: Colors.white)),
                                          ),
                                          onChanged: (value) {
                                            //변화된 id값 감지
                                            id = value;
                                          }))
                                ],
                              ),
                            ),
                            Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(top: 20),
                                width: 320,
                                child: Row(
                                  children: <Widget>[
                                    const Expanded(
                                      child: Text('비밀번호',
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 16)),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: _passwd,
                                        //set passwd controller
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                        obscureText: !_isObscure,
                                        decoration: InputDecoration(
                                            enabledBorder: const UnderlineInputBorder(
                                                borderSide:
                                                BorderSide(color: Colors.white)),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                  _isObscure
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  _isObscure = !_isObscure;
                                                });
                                              },
                                            )),
                                        onChanged: (value) {
                                          // change passwd text
                                          passwd = value;
                                        },
                                      ),
                                    )
                                  ],
                                )),
                            Container(
                                width: 400,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      child: const Text(
                                        '아이디 찾기',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (BuildContext context) =>
                                                    AlarmPage()));
                                      },
                                    ),
                                    Container(
                                      width: 1,
                                      height: 14,
                                      color: Colors.white,
                                    ),
                                    TextButton(
                                      child: const Text(
                                        '비밀번호 찾기',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (BuildContext context) =>
                                                    IndexPage()));
                                      },
                                    ),
                                    Container(
                                      width: 1,
                                      height: 14,
                                      color: Colors.white,
                                    ),
                                    TextButton(
                                      child: const Text(
                                        '회원가입',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      onPressed: () {
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (BuildContext context) =>
                                        //             FindId()));
                                      },
                                    )
                                  ],
                                )),
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                              width: 320,
                              child: SizedBox(
                                height: 48,
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    startLogin();
                                  },
                                  child: const Text(
                                    "로그인",
                                    style:
                                    TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  color: const Color.fromARGB(97, 255, 255, 255),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 320,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 48,
                                    child: RaisedButton(
                                        onPressed: _kakaoLoginButtonPressed,
                                        color: Colors.yellow,
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              'images/login/kakao.png',
                                              width: 36,
                                              height: 36,
                                              alignment: Alignment.bottomLeft,
                                            ),
                                            const Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(right: 36),
                                                  child: Text(
                                                    '카카오로 시작하기',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                )),
                                          ],
                                        )),
                                  ),
                                  Container(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 48,
                                    child: RaisedButton(
                                        onPressed: _facebookLoginButtonPressed,
                                        color: const Color.fromARGB(255, 60, 90, 154),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              'images/login/facebook.png',
                                              width: 36,
                                              height: 36,
                                              alignment: Alignment.bottomLeft,
                                            ),
                                            const Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(right: 36),
                                                  child: Text(
                                                    '페이스북으로 시작하기',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )),
                                          ],
                                        )),
                                  ),
                                  Container(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 48,
                                    child: RaisedButton(
                                        onPressed: _naverLoginButtonPressed,
                                        color: const Color.fromARGB(255, 6, 190, 52),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              'images/login/naver.png',
                                              width: 36,
                                              height: 36,
                                              alignment: Alignment.bottomLeft,
                                            ),
                                            const Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(right: 36),
                                                  child: Text(
                                                    '네이버로 시작하기',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ])),
                )),
          ));
    }
  }
  Widget errmsg(String text) {
    //error message widget.
    return Container(
      padding: const EdgeInsets.all(5.00),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.red,
          border: Border.all(color: Colors.red[300]!, width: 2)),
      child: Row(children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 6.00),
          child: const Icon(Icons.info, color: Colors.white),
        ), // icon for error message

        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        //show error message text
      ]),
    );
  }

  //뒤로가기 키 눌렀을시 뒤로가고 마지막 페이지에서 종료문구 뜨게 설정
  Future<bool> _goBack(BuildContext context) async {
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
