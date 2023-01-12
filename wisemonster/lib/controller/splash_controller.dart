import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../models/user_model.dart';

Future<ConnectivityResult> checkConnectionStatus() async {
  var result = await (Connectivity().checkConnectivity());
  if (result == ConnectivityResult.none) {
    Get.dialog(
        AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Text("알림")],
            ),
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '인터넷 연결을 확인한 후\n앱을 다시 실행해 주세요.',
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("확인"),
              onPressed: () {
                print('시스템다운');
                exit(0);
              },
            ),
          ],
        )
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
      Permission.contacts,
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.microphone].request();
    print(statuses[Permission.storage]);
    print(statuses[Permission.camera]);
    print(statuses[Permission.contacts]);
    print(statuses[Permission.location]);
    print(statuses[Permission.bluetoothScan]);
    print(statuses[Permission.bluetoothConnect]);
    print(statuses[Permission.microphone]);

    if(statuses[Permission.camera]!.isGranted
        &&statuses[Permission.storage]!.isGranted
        &&statuses[Permission.contacts]!.isGranted
        &&statuses[Permission.microphone]!.isGranted
        &&statuses[Permission.location]!.isGranted
        &&statuses[Permission.bluetoothScan]!.isGranted
        &&statuses[Permission.bluetoothConnect]!.isGranted
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
              api.getInfo().then((value)  async {
                if (value['result'] == false) {
                  Get.snackbar(
                    '알림',
                    value['message']
                    ,
                    duration: const Duration(seconds: 5),
                    backgroundColor: const Color.fromARGB(
                        255, 39, 161, 220),
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    forwardAnimationCurve: Curves.easeOutBack,
                    colorText: Colors.white,
                  );
                  print(value['message']);
                  update();
                } else {
                  Map<String, dynamic> userMap = value;
                  var user = UserModel.fromJson(userMap);
                  if( user.product_sncode_id.toString() == '0'){
                    print('등록 실패 홈');
                    Timer(const Duration(seconds: 3), () =>Get.offAll(() => registration1_view()) );
                  }else if(user.product_sncode_id.toString() != '0'){
                    Timer(const Duration(seconds: 3), () =>Get.offAll(() => home_view()) );
                  }
                  // push();
                }
              });
            }else{
              Timer(const Duration(seconds: 3), () =>Get.offAll(() => login_view()) );
            }
          });
        }
        else {
          Get.dialog(
              InitialWidget(serverMsg: '권한을 설정한 후 앱을 실행해주세요.',)
          );
        }
      });
    }
    super.onInit();
  }
}
