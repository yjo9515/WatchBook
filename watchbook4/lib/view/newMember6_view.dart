import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/newMember_controller.dart';
import 'package:watchbook4/view/login_view.dart';

class newMember6_view extends GetView<NewMemberController> {
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
            image: DecorationImage(
              image: NetworkImage('https://watchbook.tv/image/app/default/background.png'),
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
                  child:  Image.network('https://watchbook.tv/image/app/default/logo.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  ), //title text
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 46),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '환영합니다!,',
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                        Text(
                          '와치북과 함께',
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                        Text(
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
                          Get.offAll(login_view());
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