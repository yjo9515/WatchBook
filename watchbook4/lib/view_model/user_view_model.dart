import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchbook4/api/api_services.dart';
import 'package:watchbook4/models/user_model.dart';
import 'package:watchbook4/view/home_view.dart';

// 어떤 상태인지 열거
enum UserEnums {Logout, Error, Initial , Waiting}

class UserViewModel extends GetxController{

  ApiServices api = ApiServices();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  late SharedPreferences _sharedPreferences;

  UserEnums userEnums = UserEnums.Initial;

  late UserModel user;

  // 내부저장소(Preference에 값추가)
  addPref(String key, String value) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(key, value);
  }

  void login(apiId, apiPassword) {
    print(apiId);
    userEnums = UserEnums.Waiting;
    update();
    api.login(apiId, apiPassword).then((value) {
      if (value == false) {
        userEnums = UserEnums.Error;
        debugPrint('로그인 문제 발생');
      } else {
        user = UserModel.fromJson(value);
        addPref('id', user.joinId);
        update();
        Get.offAll(
                () => home_view());
      }
    });
  }




}