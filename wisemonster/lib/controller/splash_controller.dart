import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wisemonster/view/registration1_view.dart';
import 'package:wisemonster/view/splash_view.dart';
import 'package:wisemonster/view/widgets/InitialWidget.dart';
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';

import '../main.dart';

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
  RxDouble progress = 0.0.obs;
  updateProgress() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) {
      progress.value += 0.33;
      if (progress.toStringAsFixed(1) == '0.99') {
        t.cancel();
        return;
      }
      update();
    });
  }
  Future<bool>getPermission()async{
    Map<Permission,PermissionStatus>statuses = await [
      Permission.storage,
      Permission.camera,
      Permission.phone,
      Permission.location,
      Permission.contacts,
      Permission.microphone].request();
    print(statuses[Permission.storage]);
    print(statuses[Permission.camera]);
    // print(statuses[Permission.photos]);
    print(statuses[Permission.phone]);
    print('${statuses[Permission.location]} : 위치정보');
    print(statuses[Permission.contacts]);
    print(statuses[Permission.microphone]);

    if(statuses[Permission.camera]!.isGranted
        &&statuses[Permission.storage]!.isGranted
        // &&statuses[Permission.photos]!.isGranted
        &&statuses[Permission.phone]!.isGranted
        &&statuses[Permission.location]!.isGranted
        &&statuses[Permission.contacts]!.isGranted
        &&statuses[Permission.microphone]!.isGranted
    ){
      return Future.value(true);
    }
    else {
      return Future.value(false);
    }
  }


  @override
  Future<void> onInit() async {




    print('스플래쉬 진입구간');
    var result = await checkConnectionStatus();
    if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      getPermission().then((value) {
        print(value);
        if(value == true) {
          updateProgress();
          api.loginStatus().then((value) async{
            print('${value} : 스플래쉬');
            if(value != null) {
              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                  // Get.put(HomeController())
              if(sharedPreferences.getString('pcode')==null && sharedPreferences.getString('sncode')==null){
              Timer(const Duration(seconds: 3), () =>Get.offAll(() => registration1_view()) );
              }else if(sharedPreferences.getString('pcode') !=null && sharedPreferences.getString('sncode') !=null) {
              Timer(const Duration(seconds: 3), () =>Get.offAll(() => home_view()) );
              }
            }else{
              Timer(const Duration(seconds: 3), () =>Get.offAll(() => login_view()) );
            }
          });
        } else {
          Get.dialog(
              InitialWidget(serverMsg: '권한을 설정한 후 앱을 실행해주세요.',)
          );
        }
      });
    }
    super.onInit();
  }
}
