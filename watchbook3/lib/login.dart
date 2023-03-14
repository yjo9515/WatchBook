import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/all.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';
import 'package:udp/udp.dart';
import 'package:uuid/uuid.dart';
import 'package:watchbookapp/main.dart';
import 'package:web_socket_channel/io.dart';
import 'findPw.dart';
import 'welcome.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'findId.dart';

var channel;
late String _tokenValue, _idValue;
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
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
  if (result.status == LoginStatus.success) {
    // you are logged
    final AccessToken accessToken = result.accessToken!;
  } else {
    print(result.status);
    print(result.message);
  }
}

 class _LoginPage extends State<LoginPage> {
  late String errormsg;
  late bool error, showprogress;
  late String id, passwd;
  bool _isObscure = true;
  bool _isKakaoTalkInstalled = false;

  var _id = TextEditingController();
  var _passwd = TextEditingController();


  startLogin() async {
    channel = IOWebSocketChannel.connect(Uri.parse('ws://192.168.0.8:80/Echo'));
    channel.sink.add('watchbooklogin|'+_id.text.trim()+'|'+_passwd.text.trim());
    channel.stream.listen((message) {
      print(message);
      if(message == 'loginfalse'){
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
                      "이름과 수험번호를 다시 확인해주세요.",
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
      channel.sink.close(status.goingAway);
    });
  }

  @override
  void initState() {
    id = "";
    passwd = "";
    errormsg = "";
    error = false;
    KakaoContext.clientId = 'e705415345f23aab069be7b7e95e9826';
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    super.initState();
  }
  @override
  void dispose() {
    // 세로 화면 고정
    channel.sink.close();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width:
                          MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                              .size
                              .width,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: 127,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          width: 218,
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
                                    ],
                                  ),
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
                                    margin: const EdgeInsets.fromLTRB(0, 15, 0, 25),
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
                                                        WelcomePage()));
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
                                                        FindPw()));
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
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext context) =>
                                                        NewMemPage2()));
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
                                  margin: const EdgeInsets.only(bottom: 45.00),
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
                              ]),
                        ),
                      ]),
                ),
              )),
        ));
  }

  Widget errmsg(String text) {
    //에러 메세지 위젯
    return Container(
      padding: const EdgeInsets.all(10.00),
      margin: const EdgeInsets.only(bottom: 5.00),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.red,
          border: Border.all(color: Colors.red[300]!, width: 2)),
      child: Row(children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 6.00),
          child: const Icon(Icons.info, color: Colors.white),
        ), // icon for error message
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        //show error message text
      ]),
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }

  udp() async {
    var sender = await UDP.bind(Endpoint.any(port: const Port(5000)));

    // send a simple string to a broadcast endpoint on port 65001.
    var dataLength = await sender.send("Hello World!".codeUnits,
        Endpoint.broadcast(port: const Port(5001)));

    stdout.write("$dataLength bytes sent.");

    // creates a new UDP instance and binds it to the local address and the port
    // 65002.
    var receiver = await UDP.bind(Endpoint.loopback(port: const Port(5000)));

    // receiving\listening
    receiver.asStream(timeout: const Duration(seconds: 20)).listen((datagram) {
      var str = String.fromCharCodes(datagram!.data);
      stdout.write(str);

    });
    sender.close();
    receiver.close();

  }


}
