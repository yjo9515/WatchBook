import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeController extends GetxController{
  final home = Get.put(HomeViewModel());

  @override
  void onInit(){
    home.info();
    print('메인 진입');
    super.onInit();
  }

  @override
  void dispose() {
    home.sController?.close();
    home.pagecontroller?.dispose();
    home.qrcontroller?.dispose();
    print('메인종료');
    super.onClose();
  }
}