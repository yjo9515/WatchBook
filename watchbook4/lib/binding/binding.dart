import 'package:get/get.dart';
import 'package:watchbook4/controller/home_controller.dart';
import 'package:watchbook4/controller/splash_controller.dart';

class SplahBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());

    Get.lazyPut<HomeController>(() => HomeController());
  }
}