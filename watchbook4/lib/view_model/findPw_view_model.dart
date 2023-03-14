import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchbook4/api/api_services.dart';
import 'package:watchbook4/view/widgets/AlertWidget.dart';

enum UserEnums { Error, Initial, Waiting }

class FindPwViewModel extends GetxController {
  ApiServices api = ApiServices();
  UserEnums userEnums = UserEnums.Initial;

  String serverMsg = '';
  bool error = false;

  final GlobalKey<FormState> findPwFormKey = GlobalKey<FormState>();

  void findPw(apiName, apiPhone) {
    userEnums = UserEnums.Waiting;
    update();
    api.findPw(apiName, apiPhone).then((value) {
      Get.back();
      if (value == false) {
        userEnums = UserEnums.Error;
        serverMsg = "서버 연결에 실패하였습니다.";
        error = true;
        update();
      } else {
        if (kDebugMode) {
          print(value);
        }
        if (value['result'] == true) {
          error = false;
          serverMsg = '등록된 번호로 비밀번호를 전송했습니다.';
          update();
        } else {
          userEnums = UserEnums.Error;
          error = true;
          serverMsg = value['message'];
          update();
        }
        //user = UserModel.fromJson(value);
      }
      dialog(value);
    });
  }

  void dialog(value) {
    Get.dialog(
        AlertWidget(serverMsg: serverMsg, error: error)
    );
  }

}