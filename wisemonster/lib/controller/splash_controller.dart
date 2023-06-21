import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:wisemonster/view/widgets/UpdateWidget.dart';

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

  Future<String> _getAndroidStoreVersion(
      PackageInfo packageInfo) async {
    print('안드로이드 버전 호출');
    final id = packageInfo.packageName;
    final uri =
    Uri.parse("https://play.google.com/store/apps/details?id=${id}");
    final response = await http.get(uri);
    //print('${response.body} : 바디');
    if (response.statusCode != 200) {
      debugPrint('Can\'t find an app in the Play Store with the id: $id');
      return "";
    }
    final document = json.decode(response.body);
    final elements = document.getElementsByClassName('hAyfc');
    final versionElement = elements.firstWhere(
          (elm) => elm.querySelector('.BgcNfc').text == 'Current Version',
    );
    return versionElement.querySelector('.htlgb').text;
  }

  Future<dynamic> _getiOSStoreVersion(PackageInfo packageInfo) async {
    final id = packageInfo.packageName;

    final parameters = {"bundleId": "$id"};

    var uri = Uri.https("itunes.apple.com", "/lookup", parameters);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      debugPrint('Can\'t find an app in the App Store with the id: $id');
      return "";
    }

    final jsonObj = json.decode(response.body);

    /* 일반 print에서 일정 길이 이상의 문자열이 들어왔을 때,
     해당 길이만큼 문자열이 출력된 후 나머지 문자열은 잘린다.
     debugPrint의 경우 일반 print와 달리 잘리지 않고 여러 행의 문자열 형태로 출력된다. */

    // debugPrint(response.body.toString());
    return jsonObj['results'][0]['version'];
  }

  String getStoreUrlValue(String packageName, String appName) {
    if (Platform.isAndroid) {
      return "https://play.google.com/store/apps/details?id=$packageName";
    } else if (Platform.isIOS)
      return "http://apps.apple.com/kr/app/$appName/id1622131384";
    else
      return '';
  }
  addPref(String key, String value ) async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(key, value);
  }

  //jwt decode
  String decodeBase64(String str) {
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

  @override
  Future<void> onInit() async {
    print('스플래쉬 진입구간');
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    var result = await checkConnectionStatus();
    if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        print(Platform.isAndroid.toString());
        var storeVersion = Platform.isAndroid ? await _getAndroidStoreVersion(packageInfo) : Platform.isIOS ? await _getiOSStoreVersion(packageInfo) : "";

        print('my device version : ${packageInfo.version}');
        print('current store version: ${storeVersion.toString()}');
        if (storeVersion.toString().compareTo(packageInfo.version) != 0 && storeVersion.toString().compareTo("") != 0) {
          await Get.dialog(UpdateWidget());
          }
      getPermission().then((value) async {
        print(value);
        if(value == true) {
          updateProgress();
          //
          // api.loginStatus().then((value) async{
          //   print('${value} : 스플래쉬');
          //   if(value != null) {
          //     Map<String, dynamic> userMap = value;
          //     var user = UserModel.fromJson(userMap);
          //     if( user.product_sncode_id.toString() == '0'){
          //       print('등록 실패 홈');
          //       Timer(const Duration(seconds: 3), () =>Get.offAll(() => registration1_view()) );
          //     }else if(user.product_sncode_id.toString() != '0'){
          //       Timer(const Duration(seconds: 3), () =>Get.offAll(() => home_view()) );
          //     }
          //   }else{
              if(_sharedPreferences.getString('token') == null || _sharedPreferences.getString('token') == ''){
                Timer(const Duration(seconds: 3), () =>Get.offAll(() => login_view()) );
              }else{
                Map<String, dynamic> userMap;
                var user;
                try{
                  String? token = _sharedPreferences.getString('token');
                  List jwt = decodeBase64(token!).split('.');
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
                  var token = await FirebaseMessaging.instance.getToken();
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
                    Timer(const Duration(seconds: 3), () =>Get.offAll(() => home_view()) );
                    update();
                  } else if(value.statusCode == 411){
                    print('등록 실패');
                    print(user.handphone);
                    Get.offAll(() => registration1_view());
                    // api.get('/SmartdoorUserInvite/lists?name=${user.name}&handphone=${user.handphone}&isAll=1').then((value) {
                    //   if(value.statusCode == 404) {
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
                    //     print('있음');
                    //     api.post(json.encode({'smartdoor_id':user.smartdoor_id,'isOwner':user.isOwner}), '/SmartdoorUser').then((value) {
                    //       if(value.statusCode == 200){
                    //         Get.offAll(() => home_view());
                    //       }else{
                    //         Get.snackbar(
                    //           '알림',
                    //           utf8.decode(value.reasonPhrase!.codeUnits),
                    //           duration: const Duration(seconds: 5),
                    //           backgroundColor: const Color.fromARGB(
                    //               255, 39, 161, 220),
                    //           icon: const Icon(Icons.info_outline, color: Colors.white),
                    //           forwardAnimationCurve: Curves.easeOutBack,
                    //           colorText: Colors.white,
                    //         );
                    //       }
                    //
                    //     });
                    //   } else {
                    //     Get.snackbar(
                    //       '알림',
                    //       utf8.decode(value.reasonPhrase!.codeUnits),
                    //       duration: const Duration(seconds: 5),
                    //       backgroundColor: const Color.fromARGB(
                    //           255, 39, 161, 220),
                    //       icon: const Icon(Icons.info_outline, color: Colors.white),
                    //       forwardAnimationCurve: Curves.easeOutBack,
                    //       colorText: Colors.white,
                    //     );
                    //   }
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
              }

            // }
          // });
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
