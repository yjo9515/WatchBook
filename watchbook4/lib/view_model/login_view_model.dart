import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:watchbook4/api/api_services.dart';
import 'package:watchbook4/models/user_model.dart';
import 'package:watchbook4/view/home_view.dart';
import 'package:http/http.dart' as http;
import 'package:watchbook4/view/widgets/AlertWidget.dart';

// 어떤 상태인지 열거

enum UserEnums {Logout, Error, Initial , Waiting}

class LoginViewModel extends GetxController{

  ApiServices api = ApiServices();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  late SharedPreferences _sharedPreferences;

  UserEnums userEnums = UserEnums.Initial;

  late UserModel user;
  String errmsg = '';
  bool error = false;
  RxBool isObscure = true.obs;

  changeObscure() {
    if(isObscure.value == true){
      isObscure.value = false;
    } else if(isObscure.value == false){
      isObscure.value = true;
    }
    print(isObscure);
  }


  // 내부저장소(Preference에 값추가)
  addPref(String key, String value ) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(key, value);
  }

  void login(apiId, apiPassword) {
    print(apiId);
    userEnums = UserEnums.Waiting;
    update();
    api.login(apiId, apiPassword).then((value) {
      Get.back();
      if (value == false) {
        userEnums = UserEnums.Error;
        errmsg = "서버 연결에 실패하였습니다.";
        error = true;
        update();
      } else {
        print(value);
        if(value['result'] == true) {
          print(value['token']);
          addPref('token', value['token']);
          addPref('id', apiId.text);
          addPref('passwd', apiPassword.text);
          update();
          Get.offAll(
                  () => home_view());
        }else{
          userEnums = UserEnums.Error;
          error = true;
          errmsg = value['message'];
          update();
        }
        //user = UserModel.fromJson(value);
      }
    });
  }

  Future<void> kakaoLoginButtonPressed() async {
    final clientState = const Uuid().v4();
    final url = Uri.https('kauth.kakao.com', '/oauth/authorize', {
      'response_type': 'code',
      'client_id': '66bae9d5fcdbfb877a8a74edabc18f7a',
      'redirect_uri': 'https://www.watchbook.tv/oauth/kakao',
      'state': clientState,
    });
    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: "webauthcallback");
    final body = Uri.parse(result).queryParameters;
    print(body);
  }

  Future<void> naverLoginButtonPressed() async {
    final clientState = const Uuid().v4();
    final authUri = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
      'response_type': 'code',
      'client_id': 'C_TAVu2tex3Yjadne2IQ',
      'response_mode': 'form_post',
      'redirect_uri': 'https://www.watchbook.tv/oauth/naver',
      'state': clientState,
    });
    final authResponse = await FlutterWebAuth.authenticate(
        url: authUri.toString(), callbackUrlScheme: "webauthcallback");
    final code = Uri.parse(authResponse).queryParameters['code'];
    final tokenUri = Uri.https('nid.naver.com', '/oauth2.0/token', {
      'grant_type': 'authorization_code',
      'client_id': 'C_TAVu2tex3Yjadne2IQ',
      'client_secret': 'Z3ymBZN2Rd',
      'code': code,
      'state': clientState,
    });
    var tokenResult = await http.post(tokenUri);
    final accessToken = json.decode(tokenResult.body)['access_token'];
    final response = await http.get(Uri.parse(
        'https://www.watchbook.tv/oauth/naver/token?accessToken=$accessToken'));
  }

  Future<void> facebookLoginButtonPressed() async {
    final LoginResult result = await FacebookAuth.instance
        .login();
    // by default we request the email and the public profile
    // or FacebookAuth.i.login()
    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken accessToken = result.accessToken!;
    } else {
      print(result.status);
      print(result.message);
    }
  }
}