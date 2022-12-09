import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/api_services.dart';

class FindIdController extends GetxController{
  ApiServices api = ApiServices();
  @override
  void onInit() {

    super.onInit();
  }
  requestId(name,phone){
    api.findId(name,phone).then((value){
      if (value['result'] == true) {
        Get.snackbar(
          '알림',
          '등록된 번호로 문자를 전송하였습니다\n확인 후 다시 로그인해주세요.'
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }else{
        Get.snackbar(
          '알림',
          value['message']
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }
    });
  }

}