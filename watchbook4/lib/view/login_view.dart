import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/login_controller.dart';
import 'package:watchbook4/view/findId_view.dart';
import 'package:watchbook4/view/findPw_view.dart';
import 'package:watchbook4/view/newMember1_view.dart';
import 'package:watchbook4/view_model/login_view_model.dart';

class login_view extends GetView<LoginController>{
  login_view({Key? key}) : super(key: key);
  bool _isKakaoTalkInstalled = false;
  bool _isObscure = true;
  String id = '';
  String passwd = '';

  var _id = TextEditingController();
  var _passwd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent
          //color set to transperent or set your own color
        ));
    return GetBuilder<LoginViewModel>(
        init: LoginViewModel(),
        builder: (LoginViewModel) =>
            WillPopScope(
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
                        image:  DecorationImage(
                          image: NetworkImage('https://watchbook.tv/image/app/default/background.png'),
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
                                height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                                    .size
                                    .height,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                                child:Image.network('https://watchbook.tv/image/app/default/logo.png',
                                                  fit: BoxFit.contain,
                                                  alignment: Alignment.centerLeft,
                                                ) //title text
                                            ),
                                            Container(
                                              //show error message here
                                              padding: const EdgeInsets.all(10),
                                              child: LoginViewModel.error ? errmsg(LoginViewModel.errmsg) : Container(),
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
                                                            _isObscure = !_isObscure;
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
                                                  Get.to(findId_view());
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
                                                  Get.to(findPw_view());
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
                                                  Get.to(newMember1_view());
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
                                              LoginViewModel.login(_id, _passwd,);
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
                                      // Container(
                                      //   width: 320,
                                      //   margin: const EdgeInsets.only(bottom: 45.00),
                                      //   child: Column(
                                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //     children: <Widget>[
                                      //       SizedBox(
                                      //         width: MediaQuery.of(context).size.width,
                                      //         height: 48,
                                      //         child: RaisedButton(
                                      //             onPressed:(){
                                      //               LoginViewModel.kakaoLoginButtonPressed();
                                      //             },
                                      //             color: Colors.yellow,
                                      //             child: Row(
                                      //               crossAxisAlignment:
                                      //               CrossAxisAlignment.center,
                                      //               children: <Widget>[
                                      //                 Image.network(
                                      //                   'https://watchbook.tv/image/app/login/kakao.png',
                                      //                   width: 36,
                                      //                   height: 36,
                                      //                   alignment: Alignment.bottomLeft,
                                      //                 ),
                                      //                 const Expanded(
                                      //                     child: Padding(
                                      //                       padding: EdgeInsets.only(right: 36),
                                      //                       child: Text(
                                      //                         '카카오로 시작하기',
                                      //                         textAlign: TextAlign.center,
                                      //                         style: TextStyle(
                                      //                           fontSize: 14,
                                      //                           color: Colors.black87,
                                      //                         ),
                                      //                       ),
                                      //                     )),
                                      //               ],
                                      //             )),
                                      //       ),
                                      //       Container(
                                      //         height: 10,
                                      //       ),
                                      //       SizedBox(
                                      //         width: MediaQuery.of(context).size.width,
                                      //         height: 48,
                                      //         child: RaisedButton(
                                      //             onPressed: (){
                                      //               LoginViewModel.facebookLoginButtonPressed();
                                      //             },
                                      //             color: const Color.fromARGB(255, 60, 90, 154),
                                      //             child: Row(
                                      //               crossAxisAlignment:
                                      //               CrossAxisAlignment.center,
                                      //               children: <Widget>[
                                      //                 Image.network(
                                      //                   'https://watchbook.tv/image/app/login/facebook.png',
                                      //                   width: 36,
                                      //                   height: 36,
                                      //                   alignment: Alignment.bottomLeft,
                                      //                 ),
                                      //                 const Expanded(
                                      //                     child: Padding(
                                      //                       padding: EdgeInsets.only(right: 36),
                                      //                       child: Text(
                                      //                         '페이스북으로 시작하기',
                                      //                         textAlign: TextAlign.center,
                                      //                         style: TextStyle(
                                      //                           fontSize: 14,
                                      //                           color: Colors.white,
                                      //                         ),
                                      //                       ),
                                      //                     )),
                                      //               ],
                                      //             )),
                                      //       ),
                                      //       Container(
                                      //         height: 10,
                                      //       ),
                                      //       SizedBox(
                                      //         width: MediaQuery.of(context).size.width,
                                      //         height: 48,
                                      //         child: RaisedButton(
                                      //             onPressed: () {
                                      //               LoginViewModel.naverLoginButtonPressed();
                                      //             },
                                      //             color: const Color.fromARGB(255, 6, 190, 52),
                                      //             child: Row(
                                      //               crossAxisAlignment:
                                      //               CrossAxisAlignment.center,
                                      //               children: <Widget>[
                                      //                 Image.network(
                                      //                   'https://watchbook.tv/image/app/login/naver.png',
                                      //                   width: 36,
                                      //                   height: 36,
                                      //                   alignment: Alignment.bottomLeft,
                                      //                 ),
                                      //                 const Expanded(
                                      //                     child: Padding(
                                      //                       padding: EdgeInsets.only(right: 36),
                                      //                       child: Text(
                                      //                         '네이버로 시작하기',
                                      //                         textAlign: TextAlign.center,
                                      //                         style: TextStyle(
                                      //                           fontSize: 14,
                                      //                           color: Colors.white,
                                      //                         ),
                                      //                       ),
                                      //                     )),
                                      //               ],
                                      //             )),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ]),
                              ),
                            ]),
                      ),
                    )),
              )
            )
    );
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

}