import 'dart:async';
import 'package:get/get.dart';
import 'package:watchbook4/view/login_view.dart';

class SplashController extends GetxController {

  @override
  void onInit() {
    Timer(const Duration(seconds: 3),() => Get.offAll(login_view()));
    super.onInit();
  }
}