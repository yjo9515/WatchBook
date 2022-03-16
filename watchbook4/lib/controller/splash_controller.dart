import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchbook4/api/api_services.dart';
import 'package:watchbook4/view/home_view.dart';
import 'package:watchbook4/view/navigator_view.dart';

class SplashController extends GetxController {
  ApiServices api = ApiServices();
  String? tokenValue;

  @override
  void onInit() {
    print('스플래쉬 진입구간');
    if(api.loginStatus(tokenValue) == true) {
      Timer(const Duration(seconds: 3), () =>
          Get.offAll(() => home_view())
      );
    }else{
      Timer(const Duration(seconds: 3), () =>
          Get.offAll(() => navigator_view())
      );
    }

    super.onInit();
  }
}