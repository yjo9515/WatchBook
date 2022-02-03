import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchbookapp/findId.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'agreement.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'member.dart';
import 'package:http/http.dart' as http;

late String joinId,joinPw,joinRepasswd,joinNickname,joinName,joinPhone,joinType;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}
//firebase 메세지 수신시 출력


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
  bool isToken = true;
  WebViewController? _webViewController;
  final Completer<WebViewController> _controllerCompleter =
      Completer<WebViewController>();
  String id = '';
  String url = '';
  String msg = '';
  late Future<String?> currentUrl;


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
    var duration = const Duration(seconds: 2);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? tokenValue = sharedPreferences.getString('token');
    //저장된 토큰값 가져오기
    print("토큰값 : ${tokenValue}");
    if(tokenValue != null){//사용자 정보 전송
      String apiurl = 'https://www.watchbook.tv/test';
      var response = await http.post(Uri.parse(apiurl),
          headers: {HttpHeaders.authorizationHeader : "Bearer ${tokenValue}"}
      );
      print(response.headers);
      print(response.body);
    }
    return Timer(
      duration,
      () {
        setState(() {
          //타이머 시간이 지나면 스플래시 화면이 false로 (화면전환)
          loading = false;
          url = 'http://m.watchbook.tv/';
          if (tokenValue != null) {
            isToken = true;
          } else {
            isToken = false;
          }
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
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 72),
                width:
                    MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                        .size
                        .width,
                //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                height:
                    MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                        .size
                        .height,
                decoration: const BoxDecoration(
                  image: const DecorationImage(
                    image: const AssetImage('images/default/background.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        width: 218,
                        height: 34,
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'images/login_logo.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ) //title text
                        ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '지루한 공부,',
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          ),
                          const Text(
                            '와치북과',
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          ),
                          const Text(
                            '즐겁고 재밌게.',
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          )
                        ],
                      ),
                    )
                  ],
                )),
          ));
    } else {
      if (isToken == true) {
        return WillPopScope(
            onWillPop: () => _goBack(context),
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: WebView(
                  key: UniqueKey(),
                  initialUrl: url,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controllerCompleter.future
                        .then((value) => _webViewController = value);
                    _controllerCompleter.complete(webViewController);
                  },
                  javascriptMode: JavascriptMode.unrestricted,
                ),
                appBar:
                AppBar(
                  backgroundColor: Colors.white,
                  iconTheme: const IconThemeData(color:Color.fromARGB(255, 0, 104, 166)),
                  title: Image.network('https://watchbook.tv/image/app/nav/logo.png',
                    width: 87,
                    height: 18,
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                        onPressed: () async {
                          logoutProcess();
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Color.fromARGB(255, 0, 104, 166),
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
                        height: MediaQueryData.fromWindow(
                            WidgetsBinding.instance!.window)
                            .size
                            .height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              children: [
                                Container(
                                  height: 128,
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 217, 84, 84),
                                  ),
                                  child:
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const Expanded(child: CircleAvatar(
                                        radius: 40,
                                      ),),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            const Text('박보영 님', style: TextStyle(fontSize: 21, color: Colors.white, fontFamily: 'ONE_Title')),
                                            const Text('LV. 1', style: TextStyle(fontSize: 21, color: Colors.white,fontWeight: FontWeight.bold,fontFamily: 'ONE_Regular')),
                                            const Text('', style: TextStyle(fontSize: 10, color: Colors.white)),
                                            const Text('30 C', style: TextStyle(fontSize: 21, color: Colors.white,fontWeight: FontWeight.bold,fontFamily: 'ONE_Regular')),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    height: 44,
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
                                                  fontSize: 17,
                                                  fontFamily: 'ONE_Regular'
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 14,
                                          color:
                                          const Color.fromARGB(255, 207, 207, 207),
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
                                                  fontSize: 17,
                                                  fontFamily: 'ONE_Regular'
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                const Divider(
                                    color: Color.fromARGB(255, 207, 207, 207)),
                                ListTile(
                                  dense: true,
                                  title: const Text('내 강좌',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                  onTap: () => {print("")},
                                  trailing: const Icon(
                                    IconData(0xe15f,
                                        fontFamily: 'MaterialIcons',
                                        matchTextDirection: true),
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                const Divider(
                                    indent: 20,
                                    endIndent: 20,
                                    color: Color.fromARGB(255, 207, 207, 207)),
                                ListTile(
                                  dense: true,
                                  title: const Text('문제은행',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                  onTap: () => {print("settting")},
                                  trailing: const Icon(
                                    IconData(0xe15f,
                                        fontFamily: 'MaterialIcons',
                                        matchTextDirection: true),
                                    color: const Color.fromARGB(255, 0, 104, 166),
                                  ),
                                ),
                                const Divider(
                                    indent: 20,
                                    endIndent: 20,
                                    color: Color.fromARGB(255, 207, 207, 207)),
                                ListTile(
                                  dense: true,
                                  title: const Text('1:1 질문',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                  onTap: () => {print("Q&A")},
                                  trailing: const Icon(
                                      IconData(0xe15f,
                                          fontFamily: 'MaterialIcons',
                                          matchTextDirection: true),
                                      color:
                                      const Color.fromARGB(255, 0, 0, 0)),
                                ),
                                const Divider(
                                    indent: 20,
                                    endIndent: 20,
                                    color: Color.fromARGB(255, 207, 207, 207)),
                                ListTile(
                                  dense: true,
                                  title: const Text('친구목록',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                  onTap: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                Member()));
                                  },
                                  trailing: const Icon(
                                      IconData(0xe15f,
                                          fontFamily: 'MaterialIcons',
                                          matchTextDirection: true),
                                      color:
                                      const Color.fromARGB(255, 0, 0, 0)),
                                ),
                                const Divider(
                                    indent: 20,
                                    endIndent: 20,
                                    color: Color.fromARGB(255, 207, 207, 207)),
                                ListTile(
                                  dense: true,
                                  title: const Text('고객센터',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                  onTap: () => {print("Q&A")},
                                  trailing: const Icon(
                                      IconData(0xe15f,
                                          fontFamily: 'MaterialIcons',
                                          matchTextDirection: true),
                                      color:
                                      const Color.fromARGB(255, 0, 0, 0)),
                                ),
                                const Divider(
                                    indent: 20,
                                    endIndent: 20,
                                    color: Color.fromARGB(255, 207, 207, 207)),
                                ListTile(
                                  dense: true,
                                  title: const Text('도움말',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0),
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                  onTap: () => {print("Q&A")},
                                  trailing: const Icon(
                                      IconData(0xe15f,
                                          fontFamily: 'MaterialIcons',
                                          matchTextDirection: true),
                                      color:
                                      const Color.fromARGB(255, 0, 0, 0)),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                        width: 1,
                                        color: Color.fromARGB(255, 207, 207, 207),
                                      ))),
                              child: Container(
                                height: 52,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          TextButton(
                                            child: const Text(
                                              '이용약관',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                            onPressed: () {},
                                          ),
                                          Container(
                                            width: 1,
                                            height: 14,
                                            color: Colors.black,
                                          ),
                                          TextButton(
                                            child: const Text(
                                              '개인정보처리방침',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      child: const Text(
                                        '로그아웃',
                                        style: TextStyle(
                                            color: Color.fromARGB(255, 0, 36, 98),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {},
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      )
                    ],
                  ),
                ),
                // bottomNavigationBar:
                // Container(
                //   color: const Color.fromARGB(255, 246, 249, 249),
                //   height: 26,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       const Text('watchbook@naver.com')
                //     ],
                //   ),
                // )
            ));
      } else {
        return WillPopScope(
            onWillPop: () => _goBack(context),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Container(
                  padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                  width:
                      MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                          .size
                          .width,
                  //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                  height:
                      MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                          .size
                          .height,
                  decoration: const BoxDecoration(
                    image: const DecorationImage(
                      image: const AssetImage('images/default/background.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          width: 218,
                          height: 34,
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'images/login_logo.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                          ) //title text
                          ),
                      Container(
                        height: 200,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '처음 오셨나요?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 40),
                            ),
                            Container(
                              height: 106,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 48,
                                    width: double.infinity,
                                    child: RaisedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        NewMemPage()));
                                      },
                                      child: const Text(
                                        "네, 처음이에요.",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                      color: const Color.fromARGB(
                                          97, 255, 255, 255),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 48,
                                    width: double.infinity,
                                    child: RaisedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        LoginPage()));
                                      },
                                      child: const Text(
                                        "아뇨, 로그인할게요.",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                      color: const Color.fromARGB(
                                          97, 255, 255, 255),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            color: Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )),
            ));
      }
    }
  }

  void logoutProcess() async{
    SharedPreferences sharedPreferences =
    await SharedPreferences.getInstance();
    await sharedPreferences.remove('token');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => MyApp()),
            (Route<dynamic> route) => false);
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

class NewMemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.fromLTRB(0, 90, 0, 20),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: const Text(
                      '와치북만의 특별한 기능!',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  ),
                  Container(
                    height: 370,
                    margin: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                          padding: const EdgeInsets.fromLTRB(20, 20, 40, 20),
                          child: const Text(
                            '맞춤 수준의 교육컨텐츠',
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                          decoration: const BoxDecoration(
                              color: const Color.fromARGB(97, 0, 36, 98),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              )),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                          padding: const EdgeInsets.fromLTRB(20, 20, 40, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '다양한 보충 학습,',
                                style: TextStyle(
                                    fontSize: 30, color: Colors.white),
                              ),
                              const Text(
                                '반복 알고리즘',
                                style: TextStyle(
                                    fontSize: 30, color: Colors.white),
                              ),
                            ],
                          ),
                          decoration: const BoxDecoration(
                              color: const Color.fromARGB(97, 0, 36, 98),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(60),
                                bottomRight: Radius.circular(60),
                              )),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                          padding: const EdgeInsets.fromLTRB(20, 20, 40, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '서술형 채점결과를',
                                style: TextStyle(
                                    fontSize: 30, color: Colors.white),
                              ),
                              const Text(
                                '빠르고 간단하게!',
                                style: TextStyle(
                                    fontSize: 30, color: Colors.white),
                              ),
                            ],
                          ),
                          decoration: const BoxDecoration(
                              color: const Color.fromARGB(97, 0, 36, 98),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(60),
                                bottomRight: Radius.circular(60),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      NewMemPage2()));
                        },
                        child: const Text(
                          "다음으로",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        color: const Color.fromARGB(97, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ));
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}

class NewMemPage2 extends StatefulWidget {
  @override
  NewMemPage2State createState() => NewMemPage2State();
}

class NewMemPage2State extends State<NewMemPage2> {
  bool _isStudentChecked = true;
  bool _isTeacherChecked = false;
  bool? value;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '무엇을 하고 싶으세요?',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      Container(
                        height: 136,
                        margin: const EdgeInsets.only(top: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Theme(
                                data: ThemeData(
                                    unselectedWidgetColor: Colors.transparent),
                                child: CheckboxListTile(
                                    title: const Text(
                                      '학습을 하고 싶어요',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    value: _isStudentChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        _isStudentChecked = value!;
                                        _isTeacherChecked = !value;
                                      });
                                    },
                                    activeColor: Colors.transparent,
                                    // checkColor: Colors.white,
                                    isThreeLine: false,
                                    selected: _isStudentChecked),
                              ),
                              decoration: BoxDecoration(
                                color: _isStudentChecked
                                    ? const Color.fromARGB(97, 0, 36, 98)
                                    : const Color.fromARGB(97, 255, 255, 255),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              child: Theme(
                                data: ThemeData(
                                    unselectedWidgetColor: Colors.transparent),
                                child: CheckboxListTile(
                                  title: const Text(
                                    '교육을 하고 싶어요',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  value: _isTeacherChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      _isTeacherChecked = value!;
                                      _isStudentChecked = !value;
                                    });
                                  },
                                  activeColor: Colors.transparent,
                                  // checkColor: Colors.white,
                                  isThreeLine: false,
                                  selected: _isTeacherChecked,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: _isTeacherChecked
                                    ? const Color.fromARGB(97, 0, 36, 98)
                                    : const Color.fromARGB(97, 255, 255, 255),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          if (_isStudentChecked == true ||
                              _isTeacherChecked == true) {
                            if(_isTeacherChecked == false &&_isStudentChecked == true){
                              setState(() {
                                joinType = '1';
                                print(joinType);
                              });
                            }else if(_isTeacherChecked == true && _isStudentChecked == false){
                              setState(() {
                                joinType = '2';
                                print(joinType);
                              });
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        NewMemPage3()));
                          }
                        },
                        child: const Text(
                          "다음으로",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        color: const Color.fromARGB(97, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ));
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}

class NewMemPage3 extends StatefulWidget {
  @override
  NewMemPage3State createState() => NewMemPage3State();
}

class NewMemPage3State extends State<NewMemPage3> {
  bool _isAgree = false;
  bool _isEmailAgree = false;
  bool _isSMSAgree = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
              height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .height,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQueryData.fromWindow(
                            WidgetsBinding.instance!.window)
                        .size
                        .width,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                alignment: Alignment.center,
                                child: const Text('01',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    )),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 0, 104, 166),
                                    shape: BoxShape.circle),
                                width: 48,
                                height: 48,
                              ),
                            ),
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                '이용 약관 동의',
                                style: TextStyle(
                                    fontSize: 23,
                                    height: 1.6,
                                    color: Color.fromARGB(255, 0, 104, 166)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color.fromARGB(255, 0, 104, 166),
                          width: 1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  Container(
                    height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                        .size
                        .height - 350,
                    child:SingleChildScrollView(
                      child:Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromARGB(
                                            255, 207, 207, 207)
                                    )
                                )
                            ),
                            child: SizedBox(
                              width: MediaQueryData.fromWindow(
                                  WidgetsBinding.instance!.window)
                                  .size
                                  .width,
                              height: 58,
                              child: TextButton.icon(
                                onPressed: (){
                                  setState(() {
                                    if(_isAgree && _isEmailAgree && _isSMSAgree){
                                      _isAgree = false;
                                      _isEmailAgree = false;
                                      _isSMSAgree = false;
                                    }else{
                                      _isAgree = true;
                                      _isEmailAgree = true;
                                      _isSMSAgree = true;
                                    }
                                  });
                                },
                                label: Align(
                                  alignment: Alignment.centerRight,
                                  child: _isAgree && _isEmailAgree && _isSMSAgree? Image.network('https://watchbook.tv/image/app/newmem/select.png',
                                    width: 28,
                                    height: 28,
                                  ) : Image.network('https://watchbook.tv/image/app/newmem/off.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                                icon: const Text('모든 약관 확인,동의합니다.',
                                  style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 0, 0, 0)  ,
                                      fontSize: 20
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            width: MediaQueryData.fromWindow(
                                WidgetsBinding.instance!.window)
                                .size
                                .width,
                            height: 146,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _isAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                    255, 207, 207, 207), width: 1)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQueryData.fromWindow(
                                      WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  child: TextButton.icon(
                                    onPressed: (){
                                      setState(() {
                                        _isAgree = !_isAgree;
                                      });
                                    },
                                    label: Align(
                                      alignment: Alignment.centerRight,
                                      child: _isAgree ? Image.network('https://watchbook.tv/image/app/newmem/select.png',
                                        width: 28,
                                        height: 28,
                                      ) : Image.network('https://watchbook.tv/image/app/newmem/off.png',
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                    icon: Text('이용약관 전체동의 [필수]',
                                      style: TextStyle(
                                          color: _isAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                              255, 0, 0, 0) ,
                                          fontSize: 16
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQueryData.fromWindow(
                                      WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(5,16),
                                    ),
                                    onPressed: () async {
                                      _isAgree = await
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  agreement()));
                                      print(_isAgree);
                                    },
                                    label: const Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.navigate_next,size:20,color:Color.fromARGB(
                                            255, 207, 207, 207) ,
                                        )
                                    ),
                                    icon: const Text('[필수] 온라인 회원 약관 동의',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 207, 207, 207) ,
                                          fontSize: 14
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQueryData.fromWindow(
                                      WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      _isAgree = await
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  agreement()));
                                      print(_isAgree);
                                    },
                                    label: const Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.navigate_next,size:20,color:Color.fromARGB(
                                            255, 207, 207, 207) ,
                                        )
                                    ),
                                    icon: const Text('[필수] 개인정보 수집 및 이용 안내 동의',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 207, 207, 207) ,
                                          fontSize: 14
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            width: MediaQueryData.fromWindow(
                                WidgetsBinding.instance!.window)
                                .size
                                .width,
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _isEmailAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                    255, 207, 207, 207), width: 1)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQueryData.fromWindow(
                                      WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  child: TextButton.icon(
                                    onPressed: (){
                                      setState(() {
                                        _isEmailAgree = !_isEmailAgree;
                                      });
                                    },
                                    label: Align(
                                      alignment: Alignment.centerRight,
                                      child: _isEmailAgree ? Image.network('https://watchbook.tv/image/app/newmem/select.png',
                                        width: 28,
                                        height: 28,
                                      ) : Image.network('https://watchbook.tv/image/app/newmem/off.png',
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                    icon: Text('이메일 수신 동의 [선택]',
                                      style: TextStyle(
                                          color: _isEmailAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                              255, 0, 0, 0) ,
                                          fontSize: 16
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQueryData.fromWindow(
                                      WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(5,16),
                                    ),
                                    onPressed: (){
                                      setState(() {

                                      });
                                    },
                                    label: const Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.navigate_next,size:20,color:Color.fromARGB(
                                            255, 207, 207, 207) ,
                                        )
                                    ),
                                    icon: const Text('[선택] 안내 메일 수신 동의',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 207, 207, 207) ,
                                          fontSize: 14
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            width: MediaQueryData.fromWindow(
                                WidgetsBinding.instance!.window)
                                .size
                                .width,
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _isSMSAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                    255, 207, 207, 207), width: 1)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQueryData.fromWindow(
                                      WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  child: TextButton.icon(
                                    onPressed: (){
                                      setState(() {
                                        _isSMSAgree = !_isSMSAgree;
                                      });
                                    },
                                    label: Align(
                                      alignment: Alignment.centerRight,
                                      child: _isSMSAgree ? Image.network('https://watchbook.tv/image/app/newmem/select.png',
                                        width: 28,
                                        height: 28,
                                      ) : Image.network('https://watchbook.tv/image/app/newmem/off.png',
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                    icon: Text('SMS 수신 동의 [선택]',
                                      style: TextStyle(
                                          color: _isSMSAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                              255, 0, 0, 0) ,
                                          fontSize: 16
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQueryData.fromWindow(
                                      WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(5,16),
                                    ),
                                    onPressed: (){
                                      setState(() {

                                      });
                                    },
                                    label: const Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.navigate_next,size:20,color:Color.fromARGB(
                                            255, 207, 207, 207) ,
                                        )
                                    ),
                                    icon: const Text('[선택] 온라인 회원 약관 동의',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 207, 207, 207) ,
                                          fontSize: 14
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ),
                  ),
                  Container(
                    height: 106,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              if(_isAgree){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder:
                                            (BuildContext context) =>
                                                NewMemPage4()));
                              } else {
                                checkDialog();
                              }
                            },
                            child: const Text(
                              "다음으로",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            color: const Color.fromARGB(
                                255, 0, 104, 166),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color.fromARGB(
                                      255, 0, 104, 166)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "이전으로",
                              style: TextStyle(
                                  fontSize: 16, color: Color.fromARGB(
                                  255, 0, 104, 166)),
                            ),
                            color: const Color.fromARGB(
                                255, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color.fromARGB(
                                      255, 0, 104, 166)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ));
  }
  void checkDialog(){
    showDialog
      (context: context,
        barrierDismissible: false, // dialog를 제외한 다른 화면 터치 x
        builder: (BuildContext context){
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("알람")
                ],
              ),

            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "필수 이용약관에 동의해주세요",
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }

}

class NewMemPage4 extends StatefulWidget {
  @override
  NewMemPage4State createState() => NewMemPage4State();
}

class NewMemPage4State extends State<NewMemPage4> {
  String phone = '';
  String phoneAuth = '';
  String name = '';
  var _phone = TextEditingController();
  var _phoneAuth = TextEditingController();
  var _name = TextEditingController();
  var response;
  bool send = false;
  String timedisplay = "00:00";
  int timeForTimer = 0;
  bool started = true;
  Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  bool nullCheck = false;
  bool auth = false;
  bool idChk = false;
  int txt = 0; // 0일때는 숨기기 1일때는 인증완료 2일때는 인증번호틀림

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.only(top: 90),
              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
              height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .height,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                      width: MediaQueryData.fromWindow(
                          WidgetsBinding.instance!.window)
                          .size
                          .width,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text('02',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      )),
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 0, 104, 166),
                                      shape: BoxShape.circle),
                                  width: 48,
                                  height: 48,
                                ),
                              ),
                              const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '휴대폰 인증',
                                  style: TextStyle(
                                      fontSize: 23,
                                      height: 1.6,
                                      color: Color.fromARGB(255, 0, 104, 166)),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color.fromARGB(255, 0, 104, 166),
                            width: 1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(

                            width: MediaQueryData.fromWindow(
                                WidgetsBinding.instance!.window)
                                .size
                                .width,
                            margin: const EdgeInsets.only(right: 20),
                            padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                            child: const Text(
                              '휴대폰 번호를 입력해주세요.',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            decoration: const BoxDecoration(
                                color: const Color.fromARGB(
                                    255, 0, 104, 166),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(40),
                                  bottomRight: Radius.circular(40),
                                )),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 20),
                            margin: const EdgeInsets.fromLTRB(20, 30, 20, 8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 206, 206, 206)
                                  )
                              ),
                              child: TextField(
                              controller: _name, //set id controller
                              style: const TextStyle(
                                  color: const Color.fromARGB(
                                      255, 206, 206, 206), fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: '성명을 입력해 주세요.',
                                  hintStyle: TextStyle(color: const Color.fromARGB(
                                  255, 206, 206, 206)),
                                border: InputBorder.none
                              ),
                              onChanged: (value) {
                                //변화된 id값 감지
                                name = value;
                              })),
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                    flex : 74,
                                    child:Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 206, 206, 206)
                                          )
                                      ),
                                      child:  TextField(
                                          controller: _phone, //set id controller
                                          style: const TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 206, 206, 206), fontSize: 16),
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: '- 없이 입력해주세요.',
                                            hintStyle: TextStyle(color: const Color.fromARGB(
                                                255, 206, 206, 206)),
                                          ),
                                          onChanged: (value) {
                                            //변화된 id값 감지
                                            phone = value;
                                          }),
                                    )),
                                Expanded(
                                    flex: 26,
                                    child: RaisedButton(onPressed:requestSendAuthProcess,
                                      padding: const EdgeInsets.fromLTRB(0, 17, 0, 17),
                                      child:
                                      send ? const Text('재전송',
                                        style: TextStyle
                                          (color: const Color.fromARGB(
                                          255, 255, 255, 255)
                                        ,fontSize: 16),
                                      ) :
                                      const Text('전송',
                                          style: TextStyle
                                            (color: const Color.fromARGB(
                                              255, 255, 255, 255)
                                              ,fontSize: 16)),
                                      color: const Color.fromARGB(
                                          255, 108, 158, 207),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero
                                      ),
                                    )
                                )],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                            child: send ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                    flex : 55,
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Color.fromARGB(
                                                255, 206, 206, 206),
                                          ),
                                          left: BorderSide(
                                            color: Color.fromARGB(
                                                255, 206, 206, 206),
                                          ),
                                          bottom: BorderSide(
                                            color: Color.fromARGB(
                                                255, 206, 206, 206),
                                          ),
                                        )
                                      ),
                                      child: TextField(
                                          controller: _phoneAuth, //set id controller
                                          style: const TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 206, 206, 206), fontSize: 16),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '인증번호를 입력해주세요.',
                                            hintStyle: TextStyle(color: const Color.fromARGB(
                                                255, 206, 206, 206)),
                                          ),
                                          onChanged: (value) {
                                            //변화된 id값 감지
                                            phoneAuth = value;
                                          }),
                                    )),
                                Expanded(
                                  flex: 19,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 206, 206, 206),
                                            ),
                                              bottom: BorderSide(
                                                color: Color.fromARGB(
                                                    255, 206, 206, 206),
                                              )
                                          )
                                      ),
                                      padding:const EdgeInsets.fromLTRB(13, 16, 10, 16) ,
                                      child: Text(timedisplay,
                                      style: const TextStyle(
                                        color: Color.fromARGB(
                                            255, 255, 0, 0),
                                        fontSize: 14,
                                      ),),
                                    )
                                    ),
                                Expanded(
                                    flex: 26,
                                    child: RaisedButton(onPressed: requestCheckAuthProcess,
                                      padding: const EdgeInsets.fromLTRB(0, 17, 0, 17),
                                      child:
                                       const Text('인증',
                                        style: TextStyle
                                          (color: const Color.fromARGB(
                                            255, 255, 255, 255)
                                            ,fontSize: 16),
                                      ),
                                      color: const Color.fromARGB(
                                          255, 108, 158, 207),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero
                                      ),
                                    )
                                )],
                            ) : null,
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            height: 68,
                            child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                txt == 2 ?
                                const Text('* 인증번호가 일치하지 않습니다.',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 0, 0),
                                  fontSize: 14
                                ) )
                                    :
                                txt == 1 ?
                                const Text('* 인증완료 되었습니다.',
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 17, 255, 0),
                                        fontSize: 14
                                    ) )
                                : const Text('', style: TextStyle(fontSize: 14),),
                                const Text('* 입력시간 내 인증번호 6자리를 입력해주세요.',
                                style: TextStyle(fontSize: 14),),
                                const Text("* 인증번호가 오지 않는 경우 '재전송'을 클릭해주세요",
                                  style: TextStyle(fontSize: 14),)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],),
                  Container(
                    height: 106,
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              requestCheckName();
                            },
                            child: const Text(
                              "다음으로",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            color: const Color.fromARGB(
                                255, 0, 104, 166),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color.fromARGB(
                                      255, 0, 104, 166)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "이전으로",
                              style: TextStyle(
                                  fontSize: 16, color: Color.fromARGB(
                                  255, 0, 104, 166)),
                            ),
                            color: const Color.fromARGB(
                                255, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color.fromARGB(
                                      255, 0, 104, 166)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ) ),
        ));
  }
  void timerStart() {
    timeForTimer = 300; //5분설정
    _timer = new Timer.periodic(
        const Duration(
          seconds: 1,
        ), (Timer t) {
      setState(() {
        if(mounted){
          if(started == false){
            t.cancel();
            timeForTimer = timeForTimer;
          }else{
            if (timeForTimer < 1) {
              t.cancel();
              if (timeForTimer == 0) {}
              Navigator.pop(
                  context,
                  );
            } else {
              int h = timeForTimer ~/ 3600;
              int t = timeForTimer - (3600 * h);
              int m = t ~/ 60;
              int s = t - (60 * m);
              timedisplay =
                  m.toString().padLeft(2, '0') +
                  ":" +
                  s.toString().padLeft(2, '0');
              timeForTimer = timeForTimer - 1;
            }
          }
        }
      });
    });
  }

  void timerRestart() {
    setState(() {
      _timer.cancel();
       timerStart();
    });
  }

  requestSendAuthProcess() async{
    if(phone == '' || _phone == null){
      failDialog();
    }
    else{
      var timer = 300;
      String apiurl = 'https://www.watchbook.tv/User/sendSmsAuthProcess?name=${name}&handphone=${phone}&expire=${timer}';
      print(phone);
      response = await http.post(Uri.parse(apiurl),
          body: {
            'handphone': _phone.text.trim(), //get the id text
          }
      );
      print(apiurl);
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsondata = json.decode(response.body);
        if (jsondata['result'] == false) {
          failDialog();
          setState(() {
            send = false;
          });
        }else if (jsondata['result'] == true){
          checkDialog();
          setState(() {
            send = true;
          });
        }else if (jsondata['result'] == false){
          if (jsondata['message'] == "인증번호를 보낼 핸드폰 번호를 입력해 주십시오.")
          setState(() {
            nullCheck = true;
            failDialog();
          });
        }
      }
    }
  }
  requestCheckName() async{
    String url = 'https://www.watchbook.tv/User/watchbooknameCheck';
    var response = await http.post(Uri.parse(url),
        body:{
          'name' : _name.text.trim()
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      if(jsondata['result']){
        setState(() {
          auth = true;
          joinName = _name.text.trim();
          joinPhone = _phone.text.trim();
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder:
                    (BuildContext context) =>
                    NewMemPage5()));
      }else{
        if(jsondata['message'] == '이미 사용중인 이름입니다.'){
          setState(() {
            auth = false;
            idChk = false;
          });
          useIDfailDialog();
        } else if(jsondata['message'] == '이름을 입력해 주십시오.'){
          setState(() {
            auth = false;
            idChk = false;
          });
          useNamefailDialog();
        }
      }
    }
  }
  requestCheckAuthProcess() {
    Map<String, dynamic> jsondata = json.decode(response.body);
    int a = int.parse(_phoneAuth.text.trim());
    String b = jsondata['params']['authcode'].toString();
    if (a == jsondata['params']['authcode']) {// 0일때 값이 같음
      responseCheckAuthProcess();
      setState(() {
        _timer.cancel();
        timedisplay = '00:00';
        auth = true;
        txt = 1;
      });
    }else{
      setState(() {
        auth = false;
        txt = 2;
        print(b);
        print(response.body);
        print(jsondata['params']['authcode']);
        print(_phoneAuth.text.trim());
      });
    }
    //get the id text
  }

  responseCheckAuthProcess() {
    showDialog
      (context: context,
        barrierDismissible: false, // dialog를 제외한 다른 화면 터치 x
        builder: (BuildContext context){
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("알림")
                ],
              ),

            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "인증번호가 확인되었습니다.",
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("확인"),
                onPressed: () {
                  setState(() {
                    auth = true;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void checkDialog(){
    send = true;
    showDialog
      (context: context,
        barrierDismissible: false, // dialog를 제외한 다른 화면 터치 x
        builder: (BuildContext context){
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("알림")
                ],
              ),

            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "핸드폰 번호로 인증번호를 발송했습니다.\n인증번호 입력후 하단의 '확인' 버튼을 눌러주세요.",
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("확인"),
                onPressed: () {
                  setState(() {
                    send ? timerRestart() :
                    timerStart();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
  void failDialog(){
    send = false;
    showDialog
      (context: context,
        barrierDismissible: false, // dialog를 제외한 다른 화면 터치 x
        builder: (BuildContext context){
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("알림")
                ],
              ),
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                phone == '' ||  nullCheck == false?
                const Text(
                  "인증번호를 보낼 핸드폰 번호를 입력해 주십시오.",
                ) : const Text(
                  "인증번호 전송을 실패하였습니다.\n관리자에게 문의해주세요.",
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
  void useIDfailDialog(){
    showDialog
      (context: context,
        barrierDismissible: false, // dialog를 제외한 다른 화면 터치 x
        builder: (BuildContext context){
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("알림")
                ],
              ),

            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "이미 이름이 등록된 아이디가 있습니다.",
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("아이디 찾기"),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              FindId()),
                          (Route<dynamic> route) => false);
                },
              ),
              new FlatButton(
                child: const Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
  void useNamefailDialog(){
    showDialog
      (context: context,
        barrierDismissible: false, // dialog를 제외한 다른 화면 터치 x
        builder: (BuildContext context){
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("알림")
                ],
              ),
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "이름을 입력해 주십시오.",
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}

class NewMemPage5 extends StatefulWidget {
  @override
  NewMemPage5State createState() => NewMemPage5State();
}

class NewMemPage5State extends State<NewMemPage5> {
  String msg = '';
  String id = '';
  String nickname = '';
  int _isUse = 0; //1은 사용가능할때 2는 이미 있을때
  int _isUse2 = 0; //1은 사용가능할때 2는 이미 있을때
  var _id = TextEditingController();
  var _nickname = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.only(top: 90),
              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
              height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .height,
              color: Colors.white,
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                      width: MediaQueryData.fromWindow(
                          WidgetsBinding.instance!.window)
                          .size
                          .width,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text('03',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      )),
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 0, 104, 166),
                                      shape: BoxShape.circle),
                                  width: 48,
                                  height: 48,
                                ),
                              ),
                              const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '닉네임 및 아이디 설정',
                                  style: TextStyle(
                                      fontSize: 23,
                                      height: 1.6,
                                      color: Color.fromARGB(255, 0, 104, 166)),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color.fromARGB(255, 0, 104, 166),
                            width: 1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    Container(
                      height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                          .size
                          .height - 350,
                     child: SingleChildScrollView(
                       child:Column(
                         children: [
                           Container(
                             height: 220,
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               children: [
                                 Container(
                                   width: MediaQueryData.fromWindow(
                                       WidgetsBinding.instance!.window)
                                       .size
                                       .width,
                                   margin: const EdgeInsets.only(right: 20),
                                   padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                                   child: const Text(
                                     '아이디를 입력해주세요.',
                                     style: TextStyle(fontSize: 20, color: Colors.white),
                                   ),
                                   decoration: const BoxDecoration(
                                       color: const Color.fromARGB(
                                           255, 0, 104, 166),
                                       borderRadius: BorderRadius.only(
                                         topRight: Radius.circular(40),
                                         bottomRight: Radius.circular(40),
                                       )),
                                 ),
                                 Container(
                                   margin: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                                   child: Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Expanded(
                                           flex : 74,
                                           child:Container(
                                             padding: const EdgeInsets.only(left: 20),
                                             decoration: BoxDecoration(
                                                 border: Border.all(
                                                     color: const Color.fromARGB(
                                                         255, 206, 206, 206)
                                                 )
                                             ),
                                             child:  TextField(
                                                 controller: _id, //set id controller
                                                 style: const TextStyle(
                                                     color: const Color.fromARGB(
                                                         255, 206, 206, 206), fontSize: 16),
                                                 decoration: const InputDecoration(
                                                   border: InputBorder.none,
                                                   hintText: '아이디를 입력해 주세요.',
                                                   hintStyle: TextStyle(color: const Color.fromARGB(
                                                       255, 206, 206, 206)),
                                                 ),
                                                 onChanged: (value) {
                                                   //변화된 id값 감지
                                                   id = value;
                                                 }),
                                           )),
                                       Expanded(
                                           flex: 26,
                                           child: RaisedButton(onPressed:(){
                                             requestSearchId();
                                           },
                                             padding: const EdgeInsets.fromLTRB(0, 17, 0, 17),
                                             child:
                                             const Text('중복확인',
                                                 style: TextStyle
                                                   (color: const Color.fromARGB(
                                                     255, 255, 255, 255)
                                                     ,fontSize: 16)),
                                             color: const Color.fromARGB(
                                                 255, 108, 158, 207),
                                             shape: const RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.zero
                                             ),
                                           )
                                       )],
                                   ),
                                 ),
                                 _isUse == 0 ?
                                 const Text('* 사용할 아이디를 입력하시고 검색버튼을 눌러주세요.'):
                                 _isUse == 1 ?
                                 Text('* ${_id.text.trim()}는 사용가능한 아이디입니다.'
                                   ,style:const TextStyle(
                                       color: Color.fromARGB(
                                           255, 108, 158, 207)
                                   ),):
                                 _isUse == 2 ?
                                 Text('* ${_id.text.trim()}는 이미 등록된 아이디입니다.',
                                     style:const TextStyle(
                                         color: Colors.red)):
                                 _isUse == 3 ?
                                 const Text('* ID를 입력해 주세요.',
                                     style:TextStyle(
                                         color: Colors.red)):
                                 _isUse == 4 ?
                                 const Text('* 아이디를 영문, 숫자, 특수문자를 사용해 만들어 주세요.',
                                     style:TextStyle(
                                         color: Colors.red)):
                                 _isUse == 5 ?
                                 const Text('* 아이디를 최소 6자 이상으로 설정해 주세요.',
                                     style:TextStyle(
                                         color: Colors.red)):
                                 const Text('* 관리자에게 문의해주세요.'),
                               ],
                             ),
                           ),
                           Container(
                             height: 220,
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               children: [
                                 Container(
                                   width: MediaQueryData.fromWindow(
                                       WidgetsBinding.instance!.window)
                                       .size
                                       .width,
                                   margin: const EdgeInsets.only(right: 20),
                                   padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                                   child: const Text(
                                     '닉네임을 입력해주세요.',
                                     style: TextStyle(fontSize: 20, color: Colors.white),
                                   ),
                                   decoration: const BoxDecoration(
                                       color: const Color.fromARGB(
                                           255, 0, 104, 166),
                                       borderRadius: BorderRadius.only(
                                         topRight: Radius.circular(40),
                                         bottomRight: Radius.circular(40),
                                       )),
                                 ),
                                 Container(
                                   margin: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                                   child: Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Expanded(
                                           flex : 74,
                                           child:Container(
                                             padding: const EdgeInsets.only(left: 20),
                                             decoration: BoxDecoration(
                                                 border: Border.all(
                                                     color: const Color.fromARGB(
                                                         255, 206, 206, 206)
                                                 )
                                             ),
                                             child:  TextField(
                                                 controller: _nickname, //set id controller
                                                 style: const TextStyle(
                                                     color: const Color.fromARGB(
                                                         255, 206, 206, 206), fontSize: 16),
                                                 decoration: const InputDecoration(
                                                   border: InputBorder.none,
                                                   hintText: '닉네임을 입력해주세요.',
                                                   hintStyle: TextStyle(color: const Color.fromARGB(
                                                       255, 206, 206, 206)),
                                                 ),
                                                 onChanged: (value) {
                                                   //변화된 id값 감지
                                                   nickname = value;
                                                 }),
                                           )),
                                       Expanded(
                                           flex: 26,
                                           child: RaisedButton(onPressed:(){
                                             requestSearchNickname();
                                           },
                                             padding: const EdgeInsets.fromLTRB(0, 17, 0, 17),
                                             child:
                                             const Text('중복확인',
                                                 style: TextStyle
                                                   (color: const Color.fromARGB(
                                                     255, 255, 255, 255)
                                                     ,fontSize: 16)),
                                             color: const Color.fromARGB(
                                                 255, 108, 158, 207),
                                             shape: const RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.zero
                                             ),
                                           )
                                       )],
                                   ),
                                 ),
                                 _isUse2 == 0 ?
                                 const Text('* 사용할 닉네임을 입력하시고 중복확인 버튼을 눌러주세요.'):
                                 _isUse2 == 1 ?
                                 Text('* ${_nickname.text.trim()}는 사용가능한 닉네임입니다.'
                                   ,style:const TextStyle(
                                       color: Color.fromARGB(
                                           255, 108, 158, 207)
                                   ),):
                                 _isUse2 == 2 ?
                                 Text('* ${_nickname.text.trim()}는 이미 등록된 닉네임입니다.',
                                     style:const TextStyle(
                                         color: Colors.red)):
                                 _isUse2 == 3 ?
                                 const Text('* 등록할 ID를 입력해 주세요.') :
                                 const Text('* 관리자에게 문의해주세요.')
                               ],
                             ),
                           ),
                         ]
                       )
                     ),
                    )
                  ],),
                  Container(
                    height: 106,
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              if(_isUse==1 && _isUse2==1){
                                joinId = _id.text.trim();
                                joinNickname = _nickname.text.trim();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder:
                                            (BuildContext context) =>
                                            NewMemPage6()));
                              }else{
                                failDialog();
                              }
                            },
                            child: const Text(
                              "다음으로",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            color: const Color.fromARGB(
                                255, 0, 104, 166),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color.fromARGB(
                                      255, 0, 104, 166)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "이전으로",
                              style: TextStyle(
                                  fontSize: 16, color: Color.fromARGB(
                                  255, 0, 104, 166)),
                            ),
                            color: const Color.fromARGB(
                                255, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color.fromARGB(
                                      255, 0, 104, 166)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
          ),
        ));

  }
  requestSearchId() async{
    String url2 = 'https://www.watchbook.tv/User/watchbooksearchId?id=${_id.text.trim()}';
    var response = await http.post(Uri.parse(url2),
        body:{
          'id' : _id.text.trim()
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      print(jsondata['result']);
      if(jsondata['result']){
        setState(() {
          _isUse = 1;
        });
        print(_isUse);
      }
      else if(jsondata['message'] == '이미 사용중인 아이디입니다. 다른 아이디를 선택해 주세요.')
      {
        setState(() {
          _isUse = 2;
        });
      }
      else if(jsondata['message'] == '찾으실 ID를 입력해 주세요.')
      {
        setState(() {
          _isUse = 3;
        });
      }
      else if(jsondata['message'] == '아이디를 영문, 숫자, 특수문자를 사용해 만들어 주세요.')
      {
        setState(() {
          _isUse = 4;
        });
      }
      else if(jsondata['message'] == '아이디를 최소 6자 이상으로 작성해 주세요.')
      {
        setState(() {
          _isUse = 5;
        });
      } else {
        setState(() {
          _isUse = 6;
        });
      }
    }
    print(response.body);
  }

  requestSearchNickname() async{
    String url2 = 'https://www.watchbook.tv/Person/searchNickname?nickname=${_nickname.text.trim()}';
    var response = await http.post(Uri.parse(url2),
        body:{
          'nickname' : _nickname.text.trim()
        }
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      print(jsondata['result']);
      if(jsondata['result']){
        setState(() {
          _isUse2 = 1;
        });
        print(_isUse2);
      }
      else if(jsondata['message'] == '이미 사용중인 닉네임입니다. 다른 닉네임 선택해 주세요.')
      {
        setState(() {
          _isUse2 = 2;
        });
      }
      else if(jsondata['message'] == '찾으실 닉네임을 입력해 주세요.')
      {
        setState(() {
          _isUse2 = 3;
        });
      }
    }
    print(response.body);
  }
  void failDialog(){
    showDialog
      (context: context,
        barrierDismissible: false, // dialog를 제외한 다른 화면 터치 x
        builder: (BuildContext context){
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("알림")
                ],
              ),

            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "아이디와 닉네임 설정을 확인해주세요.",
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}

class NewMemPage6 extends StatefulWidget {
  @override
  NewMemPage6State createState() => NewMemPage6State();
}

class NewMemPage6State extends State<NewMemPage6> {
  bool _isObscure = true;
  bool _isObscure2 = true;
  var _passwd = TextEditingController();
  var _pwcheck = TextEditingController();
  late String passwd,pwcheck;
  int txt = 0;
  bool _allPass = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.only(top: 90),
              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
              height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .height,
              color: Colors.white,
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                      width: MediaQueryData.fromWindow(
                          WidgetsBinding.instance!.window)
                          .size
                          .width,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text('03',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      )),
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 0, 104, 166),
                                      shape: BoxShape.circle),
                                  width: 48,
                                  height: 48,
                                ),
                              ),
                              const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '비밀번호 설정',
                                  style: TextStyle(
                                      fontSize: 23,
                                      height: 1.6,
                                      color: Color.fromARGB(255, 0, 104, 166)),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color.fromARGB(255, 0, 104, 166),
                            width: 1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    Container(
                        height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                            .size
                            .height - 350,
                      child: SingleChildScrollView(
                        child:Column(
                          children: [
                            Container(
                              height: 220,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQueryData.fromWindow(
                                        WidgetsBinding.instance!.window)
                                        .size
                                        .width,
                                    margin: const EdgeInsets.only(right: 20),
                                    padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                                    child: const Text(
                                      '비밀번호를 입력해주세요.',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                    decoration: const BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 0, 104, 166),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(40),
                                          bottomRight: Radius.circular(40),
                                        )),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 206, 206, 206)
                                          )
                                      ),
                                      child: TextField(
                                        controller: _passwd,
                                        //set passwd controller
                                        style: const TextStyle(
                                            color: const Color.fromARGB(
                                                255, 206, 206, 206), fontSize: 16),
                                        obscureText: !_isObscure,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '6자리 이상 입력해주세요.',
                                            hintStyle: const TextStyle(color: Color.fromARGB(
                                                255, 206, 206, 206)),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                  _isObscure
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.black),
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
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child:
                                    txt == 1 ?
                                    const Text('* 비밀번호와 비밀번호 확인 값이 다릅니다.',
                                        style:TextStyle(
                                            color: Colors.red)):
                                    txt == 2 ?
                                    const Text('* 비밀번호를 입력해 주십시오.',
                                        style:TextStyle(
                                            color: Colors.red)):
                                    txt == 3 ?
                                    const Text('* 비밀번호를 최소 4자 이상으로 작성해 주세요.',
                                        style:TextStyle(
                                            color: Colors.red)):
                                    const Text(''),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 220,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQueryData.fromWindow(
                                        WidgetsBinding.instance!.window)
                                        .size
                                        .width,
                                    margin: const EdgeInsets.only(right: 20),
                                    padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                                    child: const Text(
                                      '비밀번호를 한 번 더 입력해주세요.',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                    decoration: const BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 0, 104, 166),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(40),
                                          bottomRight: Radius.circular(40),
                                        )),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 206, 206, 206)
                                          )
                                      ),
                                      child: TextField(
                                        controller: _pwcheck,
                                        //set passwd controller
                                        style: const TextStyle(
                                            color: const Color.fromARGB(
                                                255, 206, 206, 206), fontSize: 16),
                                        obscureText: !_isObscure2,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '비밀번호를 한 번 더 입력해주세요.',
                                            hintStyle: const TextStyle(color: Color.fromARGB(
                                                255, 206, 206, 206)),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                  _isObscure2
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Colors.black),
                                              onPressed: () {
                                                setState(() {
                                                  _isObscure2 = !_isObscure2;
                                                });
                                              },
                                            )),
                                        onChanged: (value) {
                                          // change passwd text
                                          pwcheck = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: txt == 4 ?
                                    const Text('* 비밀번호 확인을 입력해 주십시오.',
                                        style:TextStyle(
                                            color: Colors.red)):
                                    const Text(''),
                                  )
                                ],
                              ),
                            ),
                          ]
                        )
                      )
                    )
                  ],),
                  Container(
                    height: 106,
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              requestJoinProcess();
                            },
                            child: const Text(
                              "가입하기",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            color: const Color.fromARGB(
                                255, 0, 104, 166),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color.fromARGB(
                                      255, 0, 104, 166)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "이전으로",
                              style: TextStyle(
                                  fontSize: 16, color: Color.fromARGB(
                                  255, 0, 104, 166)),
                            ),
                            color: const Color.fromARGB(
                                255, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color.fromARGB(
                                      255, 0, 104, 166)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
          ),
        ));

  }
  requestJoinProcess() async {
    joinPw = _passwd.text.trim();
    joinRepasswd = _pwcheck.text.trim();
    String apiurl = 'https://www.watchbook.tv/User/watchbookjoinProcess';
    var response = await http.post(Uri.parse(apiurl),
        body: {
          'type' : joinType,
          'id' : joinId,
          'passwd' : joinPw,
          'repasswd' : joinRepasswd,
          'nickname' : joinNickname,
          'name' : joinName,
          'handphone': joinPhone, //get the id text
        }
    );
    print(response.body);
    print(joinType);
    print(joinId);
    print(joinPw);
    print(joinRepasswd);
    print(joinNickname);
    print(joinName);
    print(joinPhone);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      if (jsondata['result'] == false) {
        if (jsondata['message'] == '비밀번호와 비밀번호 확인이 다릅니다. 다시 확인해 주십시오.') {
          setState(() {
            txt = 1;
          });
        } else if (jsondata['message'] == '비밀번호를 입력해 주십시오.') {
          setState(() {
            txt = 2;
          });
        } else if (jsondata['message'] == '비밀번호를 최소 4자 이상으로 작성해 주세요.') {
          setState(() {
            txt = 3;
          });
        } else if (jsondata['message'] == '비밀번호 확인을 입력해 주십시오.') {
          setState(() {
            txt = 4;
          });
        } else {
          setState(() {
            txt = 5;
          });
        }
      } else {
        setState(() {
          _allPass == true;
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => NewMemPage7()),
                  (Route<dynamic> route) => false);
        });
      }
    }
  }

  void failDialog(){
    showDialog
      (context: context,
        barrierDismissible: false, // dialog를 제외한 다른 화면 터치 x
        builder: (BuildContext context){
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("알림")
                ],
              ),
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "아이디와 닉네임을 체크해주세요.",
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}
class NewMemPage7 extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
              width:
              MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
              height:
              MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .height,
              decoration: const BoxDecoration(
                image: const DecorationImage(
                  image: const AssetImage('images/default/background.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: 218,
                      height: 34,
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'images/login_logo.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                      ) //title text
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 46),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '환영합니다!,',
                              style: TextStyle(color: Colors.white, fontSize: 40),
                            ),
                            const Text(
                              '와치북과 함께',
                              style: TextStyle(color: Colors.white, fontSize: 40),
                            ),
                            const Text(
                              '공부하러 가볼까요?',
                              style: TextStyle(color: Colors.white, fontSize: 40),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => LoginPage()),
                                      (Route<dynamic> route) => false);
                            },
                            child: const Text(
                              "로그인",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            color: const Color.fromARGB(97, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )),
        );
  }
}
