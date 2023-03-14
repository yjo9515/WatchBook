import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login.dart';



Future<bool> _checkNotification() async {
  bool status = await Permission.notification.isGranted;
  print('알람 체크값 : ${status}');
  if (status == true) {
    return Future.value(true);
  } else {
    return Future.value(false);
  }
}

class WelcomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {

    return _welcomePage();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _welcomePage createState() => _welcomePage();

}

class _welcomePage extends State<WelcomePage> {

  WebViewController? _webViewController;
  final Completer<WebViewController> _controllerCompleter =
  Completer<WebViewController>();
  String url = 'http://watchbook.tv';
  late String msg;
  @override
  Widget build(BuildContext context) {
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
              javascriptChannels: {
                JavascriptChannel(
                    name:'JavaScriptChannel',
                    onMessageReceived: (JavascriptMessage message) async {
                      msg = message.message;
                      print(msg);
                      if(msg == 'login') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
                      }else if(msg == 'index') {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (BuildContext context) => WelcomePage()),
                                (Route<dynamic> route) => false);
                      }
                    })
              },
            ),
          ),
          appBar:
          AppBar(
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
                              content: const Text("알림 권한 설정을 확인해주세요."),
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
                  height: MediaQueryData.fromWindow(
                      WidgetsBinding.instance!.window)
                      .size
                      .height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
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
                            leading: const Icon(
                              IconData(62268, fontFamily: 'MaterialIcons'),
                              color: const Color.fromARGB(255, 0, 104, 166),
                            ),
                            title: const Text('강좌',
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 0, 104, 166),
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                            onTap: () => {print("")},
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
                            leading: const Icon(
                              Icons.edit,
                              color: const Color.fromARGB(255, 0, 104, 166),
                            ),
                            title: const Text('모의고사',
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 0, 104, 166),
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
                            leading: const Icon(
                              IconData(0xeeb8, fontFamily: 'MaterialIcons'),
                              color: const Color.fromARGB(255, 0, 104, 166),
                            ),
                            title: const Text('자격증',
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 0, 104, 166),
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                            onTap: () => {print("Q&A")},
                            trailing: const Icon(
                                IconData(0xe15f,
                                    fontFamily: 'MaterialIcons',
                                    matchTextDirection: true),
                                color:
                                const Color.fromARGB(255, 0, 104, 166)),
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
                                    color: const Color.fromARGB(
                                        255, 0, 104, 166),
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                            onTap: () => {print("Q&A")},
                            trailing: const Icon(
                                IconData(0xe15f,
                                    fontFamily: 'MaterialIcons',
                                    matchTextDirection: true),
                                color:
                                const Color.fromARGB(255, 0, 104, 166)),
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
                                    color: const Color.fromARGB(
                                        255, 0, 104, 166),
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                            onTap: () => {print("Q&A")},
                            trailing: const Icon(
                                IconData(0xe15f,
                                    fontFamily: 'MaterialIcons',
                                    matchTextDirection: true),
                                color:
                                const Color.fromARGB(255, 0, 104, 166)),
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
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
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