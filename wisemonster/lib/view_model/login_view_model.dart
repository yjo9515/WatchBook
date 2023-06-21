import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
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
    print('로그인 실행');

    // api.getInfo(json.encode({'id':apiId.text,'passwd':apiPassword.text}),'/User/login').then((value) async {
    //   if (value == false) {
    //     Get.dialog(
    //         QuitWidget(serverMsg: "로그인 토큰 발행에 실패하였습니다.",)
    //     );
    //     update();
    //   } else {
    //
    //     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //     Map<String, dynamic> userMap = value;
    //     var user = UserModel.fromJson(userMap);
    //     print(user.personObj['name']);
    //     print('일반 로그인');
    //     sharedPreferences.setString('name', user.personObj['name'].toString());
    //     sharedPreferences.setString('person_id', user.personObj['person_id'].toString());
    //     sharedPreferences.setString('family_id', user.familyId.toString());
    //     sharedPreferences.setString('family_person_id', user.familyPersonId.toString());
    //     sharedPreferences.setString('nickname', user.personObj['nickname'].toString());
    //     sharedPreferences.setString('pictureUrl', user.personObj['pictureUrl'].toString());
    //     sharedPreferences.setString('product_sncode_id', user.product_sncode_id.toString());
    //     sharedPreferences.setString('pcode', value['pcode']);
    //     sharedPreferences.setString('scode', value['scode']);
    //     sharedPreferences.setString('address', value['ble']['address']);
    //     String place = value['place'];
    //
    //     print(value['pcode']);
    //     print(value['scode']);
    //     print('${user.familyId.toString()} : familyid');
    //     print('${user.familyPersonId.toString()} : familypersonid');
    //     print(user.product_sncode_id.toString());
    //     api.sendFcmToken('/GoogleFcmToken/saveAll').then((value)  async {
    //       if (value['result'] == false) {
    //         print('fcm토큰 전송 실패');
    //       }else{
    //         print('fcm토큰 전송 성공');
    //       }
    //     });
    //     if( user.product_sncode_id.toString() == '0'){
    //       Get.offAll(() => registration1_view());
    //       print('등록 실패');
    //       update();
    //     }else if(user.product_sncode_id.toString() != '0'){
    //       Get.offAll(() => home_view());
    //       print('등록 성공');
    //       update();
    //     }
    //     update();
    //     //user = UserModel.fromJson(value);
    //   }
    // });



    api.login(apiId, apiPassword).then((value) async {

        if(value.statusCode == 200){
          String? token;
          Map<String, dynamic> userMap;
          var user;
          try{
            print('받은 토큰값 : ${value.body}');
            addPref('token', value.body.toString().trim());
            print(_decodeBase64(value.body.toString().trim()));

            // List jwt = _decodeBase64(value['token']).replaceAll('}.', '}/!').split('/!');
            List jwt = _decodeBase64(value.body.toString().trim()).split('.');
            print(jwt[1]);
            print(utf8.decode(base64.decode(jwt[1])));
            userMap = json.decode(utf8.decode(base64.decode(jwt[1])));
            user = UserModel.fromJson(userMap);
            print('일반 로그인');
            print(user.smartdoor_user_id);
            addPref('nickname', user.nickName.toString());
            addPref('smartdoor_id', user.smartdoor_id.toString());
            addPref('user_id', user.user_id.toString());
            addPref('smartdoor_user_id', user.smartdoor_user_id.toString());
            addPref('name', user.name.toString());
            addPref('handphone', user.handphone.toString());
            if(user.picture['url'] == null || user.picture['url'] == ''){
              addPref('pictureUrl', '');
            }else{
              addPref('pictureUrl', user.picture['url']);
            }
          }catch (e) {
            print(e);
            Get.back();
            Get.snackbar(
              '알림',
              '에러발생! 관리자에게 문의해주세요 (원인 : json파싱에러)'
              ,
              duration: const Duration(seconds: 5),
              backgroundColor: const Color.fromARGB(
                  255, 39, 161, 220),
              icon: const Icon(Icons.info_outline, color: Colors.white),
              forwardAnimationCurve: Curves.easeOutBack,
              colorText: Colors.white,
            );
          }
          try{
            print('firebase fcm 토큰 받기');
            token = await FirebaseMessaging.instance.getToken();
            print(token);
            api.put(json.encode({'fcm_token':token}), '/User/${user.user_id}').then((value) {
              print(value);
              if(value.statusCode != 200){
                Get.snackbar(
                  '알림',
                  utf8.decode(value.reasonPhrase!.codeUnits)
                  ,
                  duration: const Duration(seconds: 5),
                  backgroundColor: const Color.fromARGB(
                      255, 39, 161, 220),
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  forwardAnimationCurve: Curves.easeOutBack,
                  colorText: Colors.white,
                );
              }
            });
          }catch (e) {
            print(e);
            Get.back();
            Get.snackbar(
              '알림',
              '에러발생! 관리자에게 문의해주세요 (원인 : firebase fcm토큰발급)'
              ,
              duration: const Duration(seconds: 5),
              backgroundColor: const Color.fromARGB(
                  255, 39, 161, 220),
              icon: const Icon(Icons.info_outline, color: Colors.white),
              forwardAnimationCurve: Curves.easeOutBack,
              colorText: Colors.white,
            );
          }
          print('user_id');
          print(user.user_id.toString());

          api.SmartdoorMe('/Smartdoor/me').then((value) async {

            if(value.statusCode == 200){
              print('등록 성공');

              print(json.decode(value.body)['smartdoor_id']);
              print(user.smartdoor_id);
              addPref('smartdoor_id', json.decode(value.body)['smartdoor_id']);
              addPref('code', json.decode(value.body)['code']);
              Get.offAll(() => home_view());
              update();
            } else if(value.statusCode == 411){
              print('등록 실패');
              print(user.handphone);
              Get.offAll(() => registration1_view());
              // api.get('/SmartdoorUserInvite/lists?name=${user.name}&handphone=${user.handphone}&isAll=1').then((value) {
              //  if(value.statusCode == 404) {
              //     Get.offAll(() => registration1_view());
              //   } else if(value.statusCode == 401) {
              //     Get.snackbar(
              //       '알림',
              //       '로그인 토큰이 만료되었습니다. 다시 로그인하세요',
              //       duration: const Duration(seconds: 5),
              //       backgroundColor: const Color.fromARGB(
              //           255, 39, 161, 220),
              //       icon: const Icon(Icons.info_outline, color: Colors.white),
              //       forwardAnimationCurve: Curves.easeOutBack,
              //       colorText: Colors.white,
              //     );
              //   }else if(value.statusCode == 200) {
              //
              //       print('있음');
              //       api.post(json.encode({'smartdoor_id':user.smartdoor_id,'isOwner':user.isOwner}), '/SmartdoorUser').then((value) {
              //         if(value.statusCode == 200){
              //           Get.offAll(() => home_view());
              //         }else{
              //           Get.snackbar(
              //             '알림',
              //             utf8.decode(value.reasonPhrase!.codeUnits),
              //             duration: const Duration(seconds: 5),
              //             backgroundColor: const Color.fromARGB(
              //                 255, 39, 161, 220),
              //             icon: const Icon(Icons.info_outline, color: Colors.white),
              //             forwardAnimationCurve: Curves.easeOutBack,
              //             colorText: Colors.white,
              //           );
              //         }
              //
              //       });
              //   } else {
              //    Get.snackbar(
              //      '알림',
              //      utf8.decode(value.reasonPhrase!.codeUnits),
              //      duration: const Duration(seconds: 5),
              //      backgroundColor: const Color.fromARGB(
              //          255, 39, 161, 220),
              //      icon: const Icon(Icons.info_outline, color: Colors.white),
              //      forwardAnimationCurve: Curves.easeOutBack,
              //      colorText: Colors.white,
              //    );
              //  }
              // });

              update();
            }else{
              Get.back();
              Get.snackbar(
                '알림',
                utf8.decode(value.reasonPhrase!.codeUnits),
                duration: const Duration(seconds: 5),
                backgroundColor: const Color.fromARGB(
                    255, 39, 161, 220),
                icon: const Icon(Icons.info_outline, color: Colors.white),
                forwardAnimationCurve: Curves.easeOutBack,
                colorText: Colors.white,
              );
            }

          });
        }else{
          Get.back();
          Get.snackbar(
            '알림',
            utf8.decode(value.reasonPhrase!.codeUnits),
            duration: const Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: const Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        }
      });
  }

  //jwt decode
  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
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