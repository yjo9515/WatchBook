import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/newMember4_view.dart';
import 'package:wisemonster/view/newMember5_view.dart';
import 'package:wisemonster/view/widgets/AlertWidget.dart';
import 'package:wisemonster/view/widgets/InitialWidget.dart';
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import 'package:wisemonster/view/widgets/SendWidget.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';

import '../view/home_view.dart';

class NewMemberViewModel extends GetxController{



  ApiServices api = ApiServices();

  //최종
  late String joinId,joinPw,joinRepasswd,joinName,joinPhone;


  //약관 동의
  bool isAgree = false;
  bool isAgree2 = false;

  //인증페이지

  String phone = '';
  String phoneAuth = '';
  String name = '';
  var phoneController = TextEditingController();
  var phoneAuthController = TextEditingController();
  var nameController = TextEditingController();
  var idController = TextEditingController();
  var placeController = TextEditingController();
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
  int isUse = 0; //1은 사용가능할때 2는 이미 있을때
  int isUse2 = 0;
  RxBool isObscure = true.obs;
  RxBool isObscure2 = true.obs;
  var passwdController = TextEditingController();
  var pwcheckController = TextEditingController();

  String passwd= '';
  String pwcheck = '';
  String place = '';
  bool _allPass = false;
  int send = 2; //보냈는지 여부 확인 1은 보냄

  agreeChange(){
    if(isAgree && isAgree2 ){
      isAgree = false;
      isAgree2 = false;
    }else{
      isAgree = true;
      isAgree2 = true;
    }
    update();
  }

  agreeChange2(){
    isAgree = !isAgree;
    update();
  }

  agreeChange3(){
    isAgree2 = !isAgree2;
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

  // requestCheckAuthProcess() {
  //   if(nameController.text.trim().isEmpty){
  //     msg = "성명을 입력해 주세요.";
  //     initDialog(msg);
  //   }else{
  //     api.requestCheckAuthProcess(phoneAuthController).then((value) {
  //       int a = int.parse(phoneAuthController.text.trim());
  //       String b = value['params']['authcode'].toString();
  //       if (a == value['params']['authcode']) {// 0일때 값이 같음
  //         msg = "인증번호가 확인되었습니다.";
  //         initDialog(msg);
  //         timer.cancel();
  //         auth = true;
  //         txt.value = 1;
  //       }else{
  //         msg = "인증번호가 일치하지 않습니다.";
  //         initDialog(msg);
  //         txt.value = 2;
  //         print(b);
  //         print(response.body);
  //         print(value['params']['authcode']);
  //         print(phoneAuthController.text.trim());
  //       }
  //     });
  //   }
  //   //get the id text
  // }

  requestCheckName() async{
    api.requestCheckName(nameController).then((value) {
      if (value == false) {
        msg = value['message'];
        update();
      } else {
        print(value);
        if(value['result'] == true) {
          joinName = nameController.text.trim();
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

  requestValueUpdate() {
    txt.value = 0;
    msg = '';
    update();
  }

  requestJoinProcess() async{
    joinName = nameController.text.trim();
    joinId = idController.text.trim();
    joinPw = passwdController.text.trim();
    joinPhone = phoneController.text.trim();
    joinRepasswd = pwcheckController.text.trim();
    List all = [];
    all.add(joinId);
    all.add(joinPw);
    all.add(joinRepasswd);
    all.add(joinName);
    all.add(joinPhone);
    // all.add(joinPhone);
    String? token = await FirebaseMessaging.instance.getToken();
    // 보내야할거 리스트에 담아서 전송
    print(token);
    print(joinId);
    print(joinPw);
    print(joinRepasswd);

    print(joinName);
    print(joinPhone);

    api.join(json.encode({'id':joinId,'passwd':joinPw,'repasswd':joinRepasswd,'name':joinName
      ,'fcm_token':token,'handphone':joinPhone
    }), '/User').then((value) {
      if(value.statusCode == 200) {
        Get.offAll(newMember5_view());
      }else{
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits),
          duration: Duration(seconds: 3),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }
     });

    // api.requestJoinProcess(all).then((value) {
    //   if (value == false) {
    //     msg = "전송에 실패하였습니다.";
    //     error = true;
    //     update();
    //     initDialog(msg);
    //   } else {
    //     print(value);
    //     if(value['result'] == true) {
    //
    //       Get.offAll(newMember5_view());
    //     }else{
    //       msg = value['message'];
    //       print(msg);
    //       Get.snackbar(
    //           '알림',
    //           msg,
    //           duration: Duration(seconds: 3),
    //           backgroundColor: const Color.fromARGB(
    //           255, 39, 161, 220),
    //           icon: Icon(Icons.info_outline, color: Colors.white),
    //           forwardAnimationCurve: Curves.easeOutBack,
    //           colorText: Colors.white,
    //       );
    //       update();
    //     }
    //     //user = UserModel.fromJson(value);
    //   }
    // });
  }
  requestPlaceJoinProcess(sncode){
    String place = placeController.text.trim();
    // 보내야할거 리스트에 담아서 전송
    api.requestPlaceJoinProcess(sncode,place).then((value) {
      if (value['result'] == false) {
        msg = value['message'];
        error = true;
        update();
        initDialog(msg);
      } else {
          Get.dialog(
              AlertDialog(
                // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                //Dialog Main Title
                title: Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Text("알림")],
                  ),
                ),
                //
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '주소 등록이 완료되었습니다.',
                    )
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("메인으로 이동"),
                    onPressed: () {
                      Get.offAll(home_view());
                    },
                  ),
                ],
              )
          );
      }
    });
  }

  void authDialog(value) {
    Get.dialog(
        AlertWidget(serverMsg: msg, error: error)
    );
  }  void initDialog(value) {
    Get.dialog(
        QuitWidget(serverMsg: msg)
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