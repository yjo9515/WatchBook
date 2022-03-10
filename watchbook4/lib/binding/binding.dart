import 'package:get/get.dart';
import 'package:watchbook4/controller/home_controller.dart';



class HomeBinding implements Bindings{
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }

}