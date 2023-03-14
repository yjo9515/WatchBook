import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'login.dart';

class FindPw extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FindPw();
  }
}
class _FindPw extends State<FindPw> {
  String phone = '';
  String id = '';
  var _phone = TextEditingController();
  var _id = TextEditingController();
  var response;
  int? msg;
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
                      padding: const EdgeInsets.fromLTRB(0, 13, 0, 13),
                      width: MediaQueryData.fromWindow(
                          WidgetsBinding.instance!.window)
                          .size
                          .width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '비밀번호 찾기',
                            style: TextStyle(
                                fontSize: 23,
                                color: Color.fromARGB(255, 0, 104, 166)),
                          )
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
                      height: 176,
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
                              padding: const EdgeInsets.only(left: 20),
                              margin: const EdgeInsets.fromLTRB(20, 30, 20, 8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 206, 206, 206)
                                  )
                              ),
                              child: TextField(
                                  controller: _id, //set id controller
                                  style: const TextStyle(
                                      color: const Color.fromARGB(
                                          255, 206, 206, 206), fontSize: 16),
                                  decoration: const InputDecoration(
                                      hintText: '아이디',
                                      hintStyle: TextStyle(color: const Color.fromARGB(
                                          255, 206, 206, 206)),
                                      border: InputBorder.none
                                  ),
                                  onChanged: (value) {
                                    //변화된 id값 감지
                                    id = value;
                                  })),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
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
                                  controller: _phone, //set id controller
                                  style: const TextStyle(
                                      color: const Color.fromARGB(
                                          255, 206, 206, 206), fontSize: 16),
                                  decoration: const InputDecoration(
                                      hintText: '- 없이 입력해주세요.',
                                      hintStyle: TextStyle(color: const Color.fromARGB(
                                          255, 206, 206, 206)),
                                      border: InputBorder.none
                                  ),
                                  onChanged: (value) {
                                    //변화된 id값 감지
                                    setState(() {
                                      phone = value;
                                    });
                                  })),
                        ],
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
                              findPwProcess();
                            },
                            child: const Text(
                              "확인",
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
                              "닫기",
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
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
  void findPwProcess() async{
    String url = 'https://www.watchbook.tv/User/watchbookfindPasswdProcess';
    response = await http.post(Uri.parse(url),
        body: {
        'id': _id.text.trim(),
        'handphone': _phone.text.trim(),
        'type' : 'handphone'
        }
    );
    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> jsondata = json.decode(response.body);
      if (jsondata['result'] == false) {
        if (jsondata["message"] == "아이디를 입력해 주십시오.") {
          setState(() {
            msg = 1;
          });
        } else if (jsondata["message"] == "휴대전화번호를 입력해 주십시오.") {
          setState(() {
            msg = 2;
          });
        } else if (jsondata["message"] == "등록된 회원 정보가 없습니다.") {
          setState(() {
            msg = 3;
          });
        } else if (jsondata["message"] == "입력하신 정보와 일치하는 회원이 한명 이상 존재합니다. 관리자에게 문의바랍니다.") {
          setState(() {
            msg = 4;
          });
        } else {
          setState(() {
            msg = 5;
          });
        }
      }else{
        setState(() {
          msg = 0;
        });
      }
      dialog();
    }
  }
  void dialog(){
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
                msg == 0 ?
                const Text(
                  "등록된 번호로 비밀번호를 전송했습니다.",
                ) :
                msg == 1 ?
                const Text(
                  "아이디를 입력해 주십시오.",
                ) :
                msg == 2 ?
                const Text(
                  "휴대전화번호를 입력해 주십시오.",
                ) :
                msg == 3 ?
                const Text(
                  "등록된 회원 정보가 없습니다.",
                ) :
                msg == 4 ?
                const Text(
                  "입력하신 정보와 일치하는 회원이 한명 이상 존재합니다. 관리자에게 문의바랍니다.",
                ) :
                const Text(
                  "아이디찾기 메세지를 발송하는데 실패하였습니다.\n 관리자에게 문의바랍니다.",
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("확인"),
                onPressed: () {
                  if (msg == 0) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                LoginPage()),
                            (Route<dynamic> route) => false);
                  }else{
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
  }
}



