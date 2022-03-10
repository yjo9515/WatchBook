import 'dart:async';
import 'package:get/get.dart';
import 'package:watchbook4/api/api_services.dart';
import 'package:watchbook4/view/home_view.dart';
import 'package:watchbook4/view/login_view.dart';

class SplashController extends GetxController {
  ApiServices api = ApiServices();

  get tokenValue => null;
  @override
  void onInit() {
    print('스플레쉬 진입구간');
    if(api.loginStatus(tokenValue) == true) {
      Timer(const Duration(seconds: 3), () =>
          Get.offAll(() => home_view())
      );
    }else{
      Timer(const Duration(seconds: 3), () =>
          Get.offAll(() => login_view())
      );
    }
    super.onInit();
  }
}