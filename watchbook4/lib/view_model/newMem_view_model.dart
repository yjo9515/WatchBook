import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchbook4/api/api_services.dart';
import 'package:watchbook4/view/login_view.dart';
import 'package:watchbook4/view/newMember4_view.dart';
import 'package:watchbook4/view/newMember6_view.dart';
import 'package:watchbook4/view/widgets/AlertWidget.dart';
import 'package:watchbook4/view/widgets/InitialWidget.dart';
import 'package:watchbook4/view/widgets/SendWidget.dart';

class NewMemberViewModel extends GetxController{



  ApiServices api = ApiServices();

  //최종
  late String joinId,joinPw,joinRepasswd,joinNickname,joinName,joinType,joinPhone;

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
  var idController = TextEditingController();
  var nicknameController = TextEditingController();
  var response;
  bool error = false;
  String msg = '';
  var timedisplay = "00:00".obs;
  int timeForTimer = 300;
  RxString min = '0'.obs;
  RxString sec = '0'.obs;
  bool started = true;
  Timer timer = Timer(const Duration(milliseconds: 1), () {});
  bool nullCheck = false;
  bool auth = false;
  bool idChk = false;
  RxInt txt = 0.obs; // 0일때는 숨기기 1일때는 인증완료 2일때는 인증번호틀림
  String id = '';
  String nickname = '';
  int isUse = 0; //1은 사용가능할때 2는 이미 있을때
  int isUse2 = 0;
  RxBool isObscure = true.obs;
  RxBool isObscure2 = true.obs;
  var passwdController = TextEditingController();
  var pwcheckController = TextEditingController();
  late String passwd,pwcheck;
  bool _allPass = false;
  int send = 2; //보냈는지 여부 확인 1은 보냄




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
  @override
  void onClose() {
    timer.cancel();
    super.onClose();
  }
  void timerStart() {
    timer = Timer.periodic(
        const Duration(
          seconds: 1,
        ), (Timer t) {
        // if(mounted){
          if(started == false){
            t.cancel();
            timeForTimer = timeForTimer;
          }else{
            if (timeForTimer < 1) {
              min.value = '0';
              sec.value = '0';
              t.cancel();
              if (timeForTimer == 0) {
                min.value = '0';
                sec.value = '0';
                t.cancel();
              }
              Get.back();
            } else {
              print('타이머');
              int h = timeForTimer ~/ 3600;
              int t = timeForTimer - (3600 * h);
              int m = (t ~/ 60);
              int s = (t - (60 * m));
              min.value = m.toString();
              sec.value = s.toString();
              print(min.value);
              print(sec);
              // timedisplay =
              //     m.toString().padLeft(2, '0') +
              //         ":" +
              //         s.toString().padLeft(2, '0');
              timeForTimer = timeForTimer - 1;

            }
          }
        // }
     });

  }


  void timerRestart() {
    timer.cancel();
    timeForTimer = 300;
    update();
    timerStart();
  }
  requestSendAuthProcess(){
    if(nameController.text.trim().isEmpty || nameController.text.trim() == ''){
      msg = "성명을 입력해 주세요.";
      update();
      initDialog(msg);
    }else {

      api.requestSendAuthProcess(phoneController, nameController).then((value) {
        if (value == false) {
          send = 2;
          sendDialog(send);
          update();
        } else {
          print(value);
          if (value['result'] == true) {
            send = 1;
            sendDialog(send);
            update();
          } else {
            msg = "인증번호를 보낼 번호를 입력해 주십시오.";
            initDialog(msg);
            update();
          }
          //user = UserModel.fromJson(value);
        }
      });
    }
  }

  requestCheckAuthProcess() {
    if(nameController.text.trim().isEmpty){
      msg = "성명을 입력해 주세요.";
      initDialog(msg);
    }else{
      api.requestCheckAuthProcess(phoneAuthController).then((value) {
        int a = int.parse(phoneAuthController.text.trim());
        String b = value['params']['authcode'].toString();
        if (a == value['params']['authcode']) {// 0일때 값이 같음
          msg = "인증번호가 확인되었습니다.";
          initDialog(msg);
          timer.cancel();
          auth = true;
          txt.value = 1;
        }else{
          msg = "인증번호가 일치하지 않습니다.";
          initDialog(msg);
          txt.value = 2;
          print(b);
          print(response.body);
          print(value['params']['authcode']);
          print(phoneAuthController.text.trim());
        }
      });
    }
    //get the id text
  }

  requestCheckName() async{
    api.requestCheckName(nameController).then((value) {
      if (value == false) {
        msg = value['message'];
        initDialog(value);
        update();
      } else {
        print(value);
        if(value['result'] == true) {
          joinName = nameController.text.trim();
          joinPhone = phoneController.text.trim();
          Get.to(newMember4_view());
        }else{
          msg = value['message'];
          initDialog(value);
          update();
        }
        //user = UserModel.fromJson(value);
      }

    });
  }

  requestSearchId(){
    api.requestSearchId(idController).then((value) {
      if (value == false) {
        msg = "전송에 실패하였습니다.";
        error = true;
        update();
      } else {
        print(value);
        if(value['result'] == true) {
          isUse = 1;
          update();
        }else if(value['message'] == '이미 사용중인 아이디입니다. 다른 아이디를 선택해 주세요.'){
          isUse = 2;
          update();
        }else if(value['message'] == '찾으실 ID를 입력해 주세요.'){
          isUse = 3;
          update();
        }else if(value['message'] == '아이디를 영문, 숫자, 특수문자를 사용해 만들어 주세요.'){
          isUse = 4;
          update();
        }else if(value['message'] == '아이디를 최소 6자 이상으로 작성해 주세요.')
        {
          isUse = 5;
          update();
        }else{
          isUse = 6;
          update();
        }
        //user = UserModel.fromJson(value);
      }
    });
  }

  requestSearchNickname(){
    api.requestSearchNickname(nicknameController).then((value) {
      if (value == false) {
        msg = "전송에 실패하였습니다.";
        error = true;
        update();
      } else {
        print(value);
        if(value['result'] == true) {
          isUse2 = 1;
          update();
        }else if(value['message'] == '이미 사용중인 닉네임입니다. 다른 닉네임 선택해 주세요.'){
          isUse2 = 2;
          update();
        }else if(value['message'] == '찾으실 닉네임을 입력해 주세요.'){
          isUse2 = 3;
          update();
        }else{
          isUse2 = 4;
          update();
        }
        //user = UserModel.fromJson(value);
      }
    });
  }
  requestValueUpdate() {
    txt.value = 0;
    msg = '';
    update();
  }

  requestJoinProcess(){
    joinPw = passwdController.text.trim();
    joinRepasswd = pwcheckController.text.trim();
    List all = [];
    all.add(joinType);
    all.add(joinId);
    all.add(joinPw);
    all.add(joinRepasswd);
    all.add(joinNickname);
    all.add(joinName);
    all.add(joinPhone);
    // 보내야할거 리스트에 담아서 전송
    api.requestJoinProcess(all).then((value) {
      if (value == false) {
        msg = "전송에 실패하였습니다.";
        error = true;
        update();
        initDialog(msg);
      } else {
        print(value);
        if(value['result'] == true) {
          Get.offAll(newMember6_view());
        }else{
          msg = value['message'];
          update();
        }
        //user = UserModel.fromJson(value);
      }
    });
  }

  void authDialog(value) {
    Get.dialog(
        AlertWidget(serverMsg: msg, error: error)
    );
  }  void initDialog(value) {
    Get.dialog(
        InitialWidget(serverMsg: msg)
    );
  }
  void sendDialog(value) {
    Get.dialog(
        SendWidget(serverMsg: msg, send: send)
    );
    send == 2 ? timerStart() :
    timerRestart();
  }
}