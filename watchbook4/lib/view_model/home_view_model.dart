
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/login_view.dart';

class HomeViewModel extends GetxController{

  late SharedPreferences _sharedPreferences;

  void logoutProcess() async{
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences.remove('token');
    Get.offAll(
            () => 
                runApp(login_view())
            );
  }
}