import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';

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

  toggle(value,type){
    api.requestConfigSend('/ProductSncode/saveAll',type,value).then((value) {
      if (value['result'] == false) {
        print('에러발생');
      }else{
        print(value);
        Get.snackbar(
          '알림',
          '재설정 되었습니다.'
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
    }});
  }
  allupdate(){
    update();
  }
  @override
  void onInit() async{
    wifiName = await info.getWifiName(); // "FooNetwork"
    getDeviceInfo();
    api.requestConfigRead('/ProductSncodeFamily/getDataByJson').then((value) {
      if (value['result'] == false) {
        Get.snackbar(
          '알림',
          value['massage']
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );

        print(value);
        update();
      } else {
        listData = value;
        print('설정데이타');
        print(listData);
        print(listData['productSncodeObj']['isDoorbell']);
        print(listData['productSncodeObj']['isAccessRecord']);
        print(listData['productSncodeObj']['isMotionDetect']);
        if(listData['productSncodeObj']['isDoorbell'] == 1){
          isDoorbell = true;
          update();
        }else{
          isDoorbell = false;
          update();
        }
        if(listData['productSncodeObj']['isAccessRecord'] == 1){
          isAccessRecord = true;
          update();
        }else{
          isAccessRecord = false;
          update();
        }
        if(listData['productSncodeObj']['isMotionDetect'] == 1){

          isMotionDetect = true;
          print(isMotionDetect);
          update();
        }else{
          isMotionDetect = false;
          update();
        }

        update();
      }

    });
    update();
    super.onInit();
  }
}