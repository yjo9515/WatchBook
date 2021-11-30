import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/all.dart';
import 'package:get/get.dart';
//import http package manually
import 'findId.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

Future<void> _loginButtonPressed() async{
  try {
    String authCode = await AuthCodeClient.instance.request();
    print(authCode);
  } catch (e) {
    print(e.toString());
  }
}

class _LoginPage extends State<LoginPage> {
  late String errormsg;
  late bool error, showprogress;
  late String id, passwd;
  bool _isObscure = true;
  bool _isKakaoInstalled = false;

  var _id = TextEditingController();
  var _passwd = TextEditingController();

  startLogin() async {
    String apiurl = "http://watchbook.tv/User/loginProcess"; //api url
    print(id);
    var response = await http.post(Uri.parse(apiurl), body: {
      'id': id, //get the id text
      'passwd': passwd //get passwd text
    });

    if (response.statusCode == 200) {
      //정상신호 일때
      var jsondata = json.decode(response.body);
      if (jsondata["error"]) {
        setState(() {
          error = true;
          errormsg = jsondata["message"];
        });
      } else {
        if (jsondata["true"]) {
          setState(() {
            error = false;
            showprogress = false;
          });
          //save the data returned from server
          //and navigate to home page
          String id = jsondata["id"];
          print(id);
          //user shared preference to save data
        } else {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = "Something went wrong.";
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

  @override
  void initState() {
    id = "";
    passwd = "";
    errormsg = "";
    error = false;
    showprogress = false;
    KakaoContext.clientId = 'e705415345f23aab069be7b7e95e9826';
    
    _initKakaoInstalled();
    super.initState();
  }
  _initKakaoInstalled() async{
    final installed = await isKakaoTalkInstalled();
    print('kakao installed:'+installed.toString());
    setState(() {
      _isKakaoInstalled = installed;
    });
  }

  // _issueAccessToken(String authCode) async {
  //   try{
  //     var token = await AuthApi.instance.issueAccessToken(authCode);
  //     await AccessTokenStore.instance.toStore(token);
  //     Get.to(Landing());
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent
          //color set to transperent or set your own color
        ));
    return WillPopScope(
      onWillPop: () => _goBack(context),
      child:Scaffold(
        body: SingleChildScrollView(
            child: Container(
              constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height
                //set minimum height equal to 100% of VH
              ),
              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,

              //make width of outer wrapper to 100%
              decoration:  const BoxDecoration(
                image:  DecorationImage(
                  image: AssetImage('images/default/background.png'),
                  fit: BoxFit.fill,
                ),
              ),
              //show linear gradient background of page
              padding: const EdgeInsets.all(20),
              child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.fromLTRB(30, 80, 0, 0),
                        child: Image.asset('images/login_logo.png',fit: BoxFit.contain,
                        alignment:Alignment.centerLeft,
                        ) //title text

                    ),
                    Container(
                      //show error message here
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(10),
                      child: error ? errmsg(errormsg) : Container(),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: const EdgeInsets.only(top: 10),
                      width: 320,
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                              child: Text('아이디',
                                  style: TextStyle(color: Colors.white, fontSize: 16))),
                          Expanded(
                              flex: 2,
                              child: TextField(
                                  controller: _id, //set id controller
                                  style:
                                  const TextStyle(color: Colors.white, fontSize: 16),
                                  decoration: const InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white)),
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
                                  style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _passwd,
                                //set passwd controller
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                obscureText: !_isObscure,
                                decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white)),
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
                        margin: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                        padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                        width: 400,
                        child: Row(
                          crossAxisAlignment:CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              child:  const Text(
                                '아이디 찾기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => FindId())
                                );
                              },
                            ),
                            Container(
                              width: 1,
                              height: 14,
                              color: Colors.white,
                            ),

                            TextButton(
                              child:  const Text(
                                '비밀번호 찾기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => FindId())
                                );
                              },
                            ),

                            Container(
                              width: 1,
                              height: 14,
                              color: Colors.white,
                            ),

                            TextButton(
                              child:  const Text(
                                '회원가입',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => FindId())
                                );
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
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                        children:<Widget> [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child:
                            RaisedButton(
                                onPressed: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => FindId())
                                  );
                                },
                                color: Colors.yellow,
                                child:
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children:<Widget>[
                                      Image.asset('images/login/kakao.png',
                                        width: 36,height: 36,
                                        alignment: Alignment.bottomLeft,
                                      ),

                                    const Expanded(
                                        child:
                                            Padding(padding: EdgeInsets.only(right: 36),
                                             child: TextButton(
                                               onPressed: _loginButtonPressed,
                                               child: Text(
                                                 '카카오로 시작하기',
                                                 textAlign: TextAlign.center,
                                                 style: TextStyle(
                                                   fontSize: 14,
                                                   color: Colors.black87,
                                                 ),
                                               ),
                                             ),
                                            )
                                    ),
                                  ],
                                )
                            ),
                          ),
                          Container(
                            height: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child: RaisedButton(

                                onPressed: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => FindId())
                                  );
                                },
                                color: const Color.fromARGB(255, 60, 90, 154),
                                child:Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children:<Widget>[
                                      Image.asset('images/login/facebook.png',
                                        width: 36,height: 36,
                                        alignment: Alignment.bottomLeft,
                                      ),
                                    const Expanded(
                                        child:
                                        Padding(padding: EdgeInsets.only(right: 36),
                                          child: Text(
                                            '페이스북으로 시작하기',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                    ),
                                  ],

                                )

                            ),

                          ),
                          Container(
                            height: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child: RaisedButton(

                                onPressed: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => FindId())
                                  );
                                },
                                color: const Color.fromARGB(255, 6, 190, 52),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children:<Widget>[
                                      Image.asset('images/login/naver.png',
                                        width: 36,height: 36,
                                        alignment: Alignment.bottomLeft,
                                      ),
                                    const Expanded(
                                        child:
                                        Padding(padding: EdgeInsets.only(right: 36),
                                          child: Text(
                                            '네이버로 시작하기',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                    ),
                                  ],
                                )

                            ),

                          ),
                        ],
                      ),
                    ),
                  ])),
            )),
      )
    );
  }

  Widget errmsg(String text) {
    //error message widget.
    return Container(
      padding: const EdgeInsets.all(15.00),
      margin: const EdgeInsets.only(bottom: 10.00),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.red,
          border: Border.all(color: Colors.red[300]!, width: 2)),
      child: Row(children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 6.00),
          child: const Icon(Icons.info, color: Colors.white),
        ), // icon for error message

        Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
        //show error message text
      ]),
    );
  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }

}
