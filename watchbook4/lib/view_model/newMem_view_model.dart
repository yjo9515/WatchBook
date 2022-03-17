import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchbook4/api/api_services.dart';
import 'package:watchbook4/view/widgets/AlertWidget.dart';

class NewMemberViewModel extends GetxController{
  ApiServices api = ApiServices();
  //학생 교사 구분
  bool isStudentChecked = true;
  bool isTeacherChecked = false;

  //약관 동의
  bool isAgree = false;
  bool isEmailAgree = false;
  bool isSMSAgree = false;

  //인증페이지

  String phone = '';
  String phoneAuth = '';
  String name = '';
  var phoneController = TextEditingController();
  var phoneAuthController = TextEditingController();
  var nameController = TextEditingController();
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


  var joinType;
  firstChange(value){
    isStudentChecked = value!;
    isTeacherChecked = !value;
    update();
  }
  secondChange(value){
    isTeacherChecked = value!;
    isStudentChecked = !value;
    update();
  }

  agreeChange(){
    if(isAgree && isEmailAgree && isSMSAgree){
      isAgree = false;
      isEmailAgree = false;
      isSMSAgree = false;
    }else{
      isAgree = true;
      isEmailAgree = true;
      isSMSAgree = true;
    }
    update();
  }

  agreeChange2(){
    isAgree = !isAgree;
    update();
  }

  agreeChange3(){
    isEmailAgree = !isEmailAgree;
    update();
  }

  smsAgree(){
    isSMSAgree = !isSMSAgree;
    update();
  }

  void dialog() {
    Get.dialog(
        AlertWidget(serverMsg: '필수 이용약관에 동의해주세요.', error: true,)
    );
  }

  void timerStart() {
    timeForTimer = 300; //5분설정
    _timer = Timer.periodic(
        const Duration(
          seconds: 1,
        ), (Timer t) {

        // if(mounted){
          if(started == false){
            t.cancel();
            timeForTimer = timeForTimer;
          }else{
            if (timeForTimer < 1) {
              t.cancel();
              if (timeForTimer == 0) {}
              Get.back();
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
        // }
        update();
    });
  }

  void timerRestart() {
    _timer.cancel();
    timerStart();
    update();
  }
  requestSendAuthProcess(){
    api.login(apiId, apiPassword).then((value) {
      Get.back();
      if (value == false) {
        errmsg = "서버 연결에 실패하였습니다.";
        error = true;
        update();
      } else {
        print(value);
        if(value['result'] == true) {
          print(value['token']);
          addPref('token', value['token']);
          update();
          Get.offAll(
                  () => home_view());
        }else{
          error = true;
          errmsg = value['message'];
          update();
        }
        //user = UserModel.fromJson(value);
      }
    });
  }
}