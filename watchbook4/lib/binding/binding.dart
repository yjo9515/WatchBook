import 'package:get/get.dart';
import 'package:watchbook4/controller/login_controller.dart';
import 'package:watchbook4/controller/splash_controller.dart';

class SplahBinding implements Bindings{
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}
class LoginBinding implements Bindings{
  @override
  void dependencies() {
    Get.put(LoginController());
  }
}