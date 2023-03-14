import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/models/user_model.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:http/http.dart' as http;
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/widgets/AlertWidget.dart';
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';

import '../view/registration1_view.dart';
import '../view/registration2_view.dart';

// 어떤 상태인지 열거

enum UserEnums {Logout, Error, Initial , Waiting}

class LoginViewModel extends GetxController{

  ApiServices api = ApiServices();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  late SharedPreferences _sharedPreferences;

  UserEnums userEnums = UserEnums.Initial;
 bool passwordVisible = false;
  late UserModel user;
  String errmsg = '';
  bool error = false;
  var product_sncode;

  void logoutProcess() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    // await _sharedPreferences.clear();
    // await _sharedPreferences.remove('name');
    // await _sharedPreferences.remove('pcode');
    // await _sharedPreferences.remove('sncode');
    // await _sharedPreferences.remove('id');
    // await _sharedPreferences.remove('passwd');
    await _sharedPreferences.remove('token');
    await _sharedPreferences.remove('pictureUrl');
    print('로그아웃');
    // await Get.deleteAll(force: true); //deleting all controllers
    Phoenix.rebirth(Get.context!); // Restarting app
    Get.reset(); // resetting getx
  }


  changeObscure() {
    if(passwordVisible == true){
      passwordVisible = false;
    } else if(passwordVisible == false){
      passwordVisible = true;
    }
    print(passwordVisible);
    update();
  }
  //
  // autoLogin() {
  //   if(isAuto.value == true){
  //     isAuto.value = false;
  //   } else if(isAuto.value == false){
  //     isAuto.value = true;
  //   }
  //   print(isAuto);
  // }


  // 내부저장소(Preference에 값추가)
  addPref(String key, String value ) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(key, value);
  }

  void login(apiId, apiPassword) {
    print(apiId);
    userEnums = UserEnums.Waiting;
    api.login(apiId, apiPassword).then((value) {
      if (value == false) {
        Get.back();
        Get.dialog(
            QuitWidget(serverMsg: "서버 연결에 실패하였습니다.",)
        );
        update();
      } else {
        print(value);
        if(value['result'] == true){
          print(value['token']);
          addPref('token', value['token']);
          addPref('id', apiId.text);
          api.getInfo().then((value) async {
            if (value == false) {
              Get.dialog(
                  QuitWidget(serverMsg: "로그인 토큰 발행에 실패하였습니다.",)
              );
              update();
            } else {
              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
              Map<String, dynamic> userMap = value;
              var user = UserModel.fromJson(userMap);
              print(user.personObj['name']);
              print('일반 로그인');
              sharedPreferences.setString('name', user.personObj['name'].toString());
              sharedPreferences.setString('person_id', user.personObj['person_id'].toString());
              sharedPreferences.setString('family_id', user.familyId.toString());
              sharedPreferences.setString('family_person_id', user.familyPersonId.toString());
              sharedPreferences.setString('nickname', user.personObj['nickname'].toString());
              sharedPreferences.setString('pictureUrl', user.personObj['pictureUrl'].toString());
              sharedPreferences.setString('product_sncode_id', user.product_sncode_id.toString());
              sharedPreferences.setString('pcode', value['pcode']);
              sharedPreferences.setString('scode', value['scode']);
              sharedPreferences.setString('address', value['ble']['address']);
              String place = value['place'];

              print(value['pcode']);
              print(value['scode']);
              print('${user.familyId.toString()} : familyid');
              print('${user.familyPersonId.toString()} : familypersonid');
              print(user.product_sncode_id.toString());
              api.sendFcmToken('/GoogleFcmToken/saveAll').then((value)  async {
                if (value['result'] == false) {
                  print('fcm토큰 전송 실패');
                }else{
                  print('fcm토큰 전송 성공');
                }
              });
              if( user.product_sncode_id.toString() == '0'){
                Get.offAll(() => registration1_view());
                print('등록 실패');
                update();
              }else if(user.product_sncode_id.toString() != '0'){
                Get.offAll(() => home_view());
                print('등록 성공');
                update();
              }
              update();
              //user = UserModel.fromJson(value);
            }
          });
        }
        else {
          Get.back();
          Get.snackbar(
            '알림',
            // '다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.'
            value['message']
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        }



      }
      });
  }


  // Future<void> kakaoLoginButtonPressed() async {
  //   final clientState = const Uuid().v4();
  //   final url = Uri.https('kauth.kakao.com', '/oauth/authorize', {
  //     'response_type': 'code',
  //     'client_id': '66bae9d5fcdbfb877a8a74edabc18f7a',
  //     'redirect_uri': 'https://www.watchbook.tv/oauth/kakao',
  //     'state': clientState,
  //   });
  //   final result = await FlutterWebAuth.authenticate(
  //       url: url.toString(), callbackUrlScheme: "webauthcallback");
  //   final body = Uri.parse(result).queryParameters;
  //   print(body);
  // }
  //
  // Future<void> naverLoginButtonPressed() async {
  //   final clientState = const Uuid().v4();
  //   final authUri = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
  //     'response_type': 'code',
  //     'client_id': 'C_TAVu2tex3Yjadne2IQ',
  //     'response_mode': 'form_post',
  //     'redirect_uri': 'https://www.watchbook.tv/oauth/naver',
  //     'state': clientState,
  //   });
  //   final authResponse = await FlutterWebAuth.authenticate(
  //       url: authUri.toString(), callbackUrlScheme: "webauthcallback");
  //   final code = Uri.parse(authResponse).queryParameters['code'];
  //   final tokenUri = Uri.https('nid.naver.com', '/oauth2.0/token', {
  //     'grant_type': 'authorization_code',
  //     'client_id': 'C_TAVu2tex3Yjadne2IQ',
  //     'client_secret': 'Z3ymBZN2Rd',
  //     'code': code,
  //     'state': clientState,
  //   });
  //   var tokenResult = await http.post(tokenUri);
  //   final accessToken = json.decode(tokenResult.body)['access_token'];
  //   final response = await http.get(Uri.parse(
  //       'https://www.watchbook.tv/oauth/naver/token?accessToken=$accessToken'));
  // }
  //
  // Future<void> facebookLoginButtonPressed() async {
  //   final LoginResult result = await FacebookAuth.instance
  //       .login();
  //   // by default we request the email and the public profile
  //   // or FacebookAuth.i.login()
  //   if (result.status == LoginStatus.success) {
  //     // you are logged
  //     final AccessToken accessToken = result.accessToken!;
  //   } else {
  //     print(result.status);
  //     print(result.message);
  //   }
  // }




  @override
  void onInit() {

    print('로그인 진입구간');
    super.onInit();
  }
  @override
  void onClose() {
    print('로그인 다운');
    super.onClose();
  }
}