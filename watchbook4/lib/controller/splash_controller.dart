import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchbook4/api/api_services.dart';
import 'package:watchbook4/controller/home_controller.dart';
import 'package:watchbook4/view/home_view.dart';
import 'package:watchbook4/view/navigator_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:watchbook4/view/widgets/QuitWidget.dart';

Future<ConnectivityResult> checkConnectionStatus() async {
  var result = await (Connectivity().checkConnectivity());
  if (result == ConnectivityResult.none) {
    Get.dialog(
        QuitWidget(serverMsg: '인터넷 연결을 확인한 후\n앱을 다시 실행해 주세요.')
    );
  }

  return result;  // wifi, mobile
}

class SplashController extends GetxController {
  ApiServices api = ApiServices();
  String value = '';
  @override
  Future<void> onInit() async {
    print('스플래쉬 진입구간');
    var result = await checkConnectionStatus();
    if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      api.loginStatus().then((value) {
        print(value);
        if(value != null) {
          Timer(const Duration(seconds: 3), () =>
              Get.put(HomeController())
          );
        }else{
          Timer(const Duration(seconds: 3), () =>
              Get.offAll(() => navigator_view())
          );
        }
      });
    }

    super.onInit();
  }
}