import 'dart:async';
import 'package:get/get.dart';
import 'package:watchbook4/view/login_view.dart';

class SplashController extends GetxController {

  @override
  void onInit() {
    print('dd');
    Timer(const Duration(seconds: 3),() => Get.offAll(login_view()));
    update();
    super.onInit();
    print('dd');
  }
}