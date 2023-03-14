import 'dart:io';

import 'package:get/get.dart';
import 'package:watchbook4/view/home_view.dart';
import 'package:watchbook4/view_model/home_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeController extends GetxController{
  HomeViewModel home = HomeViewModel();
  @override
  void onInit() {
    home.info();
    print('메인 진입');
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.onInit();
  }
}