import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/login_view.dart';

import '../api/api_services.dart';

class ConfigController extends GetxController{
  ApiServices api = ApiServices();
  final info = NetworkInfo();
  var wifiName;
  Map<String, dynamic> deviceData = <String, dynamic>{};
  var listData;
  bool isDoorbell = false;
  bool isAccessRecord = false;
  bool isMotionDetect = false;
  String? token;
  var k = TextEditingController();
  String test = '';

  Future<Map<String, dynamic>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidDeviceInfo(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } catch(error) {
      deviceData = {
        "Error": "Failed to get platform version."
      };
    }

    return deviceData;
  }

  Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo info) {
    var release = info.version.release;
    var sdkInt = info.version.sdkInt;
    var manufacturer = info.manufacturer;
    var model = info.model;

    return {
      "OS 버전": "Android $release (SDK $sdkInt)",
      "기기": "$manufacturer $model"
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo info) {
    var systemName = info.systemName;
    var version = info.systemVersion;
    var machine = info.utsname.machine;

    return {
      "OS 버전": "$systemName $version",
      "기기": "$machine"
    };
  }

  toggle(value,type) async {
    print('토글 값');
    print(value);
    String? toggleValue;
    if(value == true){
      toggleValue = '1';
    } else {
      toggleValue = '0';
    }
    late SharedPreferences sharedPreferences;
    sharedPreferences = await SharedPreferences.getInstance();
    print(type);
    if(type == 'isDoorbell') {
      print(toggle);
      print(toggleValue);
      api.put(
          json.encode({
            'isDoorbell':toggleValue})
          , '/SmartdoorUser').then((value) {
        if(value.statusCode == 200) {
          Get.snackbar(
            '알림',
            '도어벨 알림이 재설정 되었습니다.'
            ,
            duration: Duration(seconds: 3),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        } else if(value.statusCode == 401) {
          Get.offAll(login_view());
          Get.snackbar(
            '알림',
            utf8.decode(value.reasonPhrase!.codeUnits)
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            '알림',
            utf8.decode(value.reasonPhrase!.codeUnits)
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        }
      });
    } else if(type == 'isAccessRecord') {
      api.put(
          json.encode({
            'isAccessRecord':toggleValue})
          , '/SmartdoorUser').then((value) {
        if(value.statusCode == 200) {
          Get.snackbar(
            '알림',
            '출입 알림이 재설정 되었습니다.'
            ,
            duration: Duration(seconds: 3),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        } else if(value.statusCode == 401) {
          Get.offAll(login_view());
          Get.snackbar(
            '알림',
            utf8.decode(value.reasonPhrase!.codeUnits)
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            '알림',
            utf8.decode(value.reasonPhrase!.codeUnits)
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        }
      });
    } else if(type == 'isMotionDetect') {
      api.put(
          json.encode({
            'isMotionDetect':toggleValue})
          , '/SmartdoorUser').then((value) {
        if(value.statusCode == 200) {
          Get.snackbar(
            '알림',
            '모션감지 알림이 재설정 되었습니다.'
            ,
            duration: Duration(seconds: 3),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        } else if(value.statusCode == 401) {
          Get.offAll(login_view());
          Get.snackbar(
            '알림',
            utf8.decode(value.reasonPhrase!.codeUnits)
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            '알림',
            utf8.decode(value.reasonPhrase!.codeUnits)
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        }
      });
    }

    // api.requestConfigSend('/ProductSncode/saveAll',type,value).then((value) {
    //   if (value['result'] == false) {
    //     print('에러발생');
    //   }else{
    //     print(value);
    //     Get.snackbar(
    //       '알림',
    //       '재설정 되었습니다.'
    //       ,
    //       duration: Duration(seconds: 5),
    //       backgroundColor: const Color.fromARGB(
    //           255, 39, 161, 220),
    //       icon: Icon(Icons.info_outline, color: Colors.white),
    //       forwardAnimationCurve: Curves.easeOutBack,
    //       colorText: Colors.white,
    //     );
    // }});
    update();
  }
  allupdate(){
    update();
  }
  @override
  void onInit() async{
    token = await FirebaseMessaging.instance.getToken();
    test = token!;
    k.text = token!;
    update();
    wifiName = await info.getWifiName(); // "FooNetwork"
    getDeviceInfo();
    late SharedPreferences sharedPreferences;
    sharedPreferences = await SharedPreferences.getInstance();
    api.get('/SmartdoorUser/me').then((value) {

      if(value.statusCode == 200) {
        listData = json.decode(value.body);
        print('설정데이타');
        print(listData);
        print(listData['isDoorbell']);
        print(listData['isAccessRecord']);
        print(listData['isMotionDetect']);
        if(listData['isDoorbell'] == 1){
          isDoorbell = true;
          update();
        }else{
          isDoorbell = false;
          update();
        }
        if(listData['isAccessRecord'] == 1){
          isAccessRecord = true;
          update();
        }else{
          isAccessRecord = false;
          update();
        }
        if(listData['isMotionDetect'] == 1){
          isMotionDetect = true;
          print(isMotionDetect);
          update();
        }else{
          isMotionDetect = false;
          update();
        }
      } else if(value.statusCode == 401) {
        Get.offAll(login_view());
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }

    });
    // api.requestConfigRead('/SmartdoorUser/${ sharedPreferences.getString('smartdoor_user_id')}').then((value) {
    //   if (value['result'] == false) {
    //     Get.snackbar(
    //       '알림',
    //       value['massage']
    //       ,
    //       duration: Duration(seconds: 5),
    //       backgroundColor: const Color.fromARGB(
    //           255, 39, 161, 220),
    //       icon: Icon(Icons.info_outline, color: Colors.white),
    //       forwardAnimationCurve: Curves.easeOutBack,
    //       colorText: Colors.white,
    //     );
    //
    //     print(value);
    //     update();
    //   } else {
    //     listData = value;
    //     print('설정데이타');
    //     print(listData);
    //     print(listData['productSncodeObj']['isDoorbell']);
    //     print(listData['productSncodeObj']['isAccessRecord']);
    //     print(listData['productSncodeObj']['isMotionDetect']);
    //     if(listData['productSncodeObj']['isDoorbell'] == 1){
    //       isDoorbell = true;
    //       update();
    //     }else{
    //       isDoorbell = false;
    //       update();
    //     }
    //     if(listData['productSncodeObj']['isAccessRecord'] == 1){
    //       isAccessRecord = true;
    //       update();
    //     }else{
    //       isAccessRecord = false;
    //       update();
    //     }
    //     if(listData['productSncodeObj']['isMotionDetect'] == 1){
    //
    //       isMotionDetect = true;
    //       print(isMotionDetect);
    //       update();
    //     }else{
    //       isMotionDetect = false;
    //       update();
    //     }
    //
    //     update();
    //   }
    //
    // });
    update();
    super.onInit();
  }
}