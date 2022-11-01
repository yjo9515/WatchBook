
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/src/types/barcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/models/user_model.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import '../view/login_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeViewModel extends GetxController{
  ApiServices api = ApiServices();
  late SharedPreferences sharedPreferences;
  String? id;
  String? passwd;
  RxString userName = ''.obs;
  String msg = '';
  bool error = false;
  bool register = false;

  Barcode? result;
  QRViewController? qrcontroller;


  final PageController pagecontroller = PageController(initialPage: 0, );
  StreamController sController = StreamController<int>()..add(0);

  void logoutProcess() async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove('token');
    await sharedPreferences.remove('name');
    await sharedPreferences.remove('pcode');
    await sharedPreferences.remove('sncode');
    await sharedPreferences.remove('id');
    await sharedPreferences.remove('passwd');


    print('로그아웃');
    Get.offAll(() => login_view());
  }

  void info() {
    api.getInfo().then((value)  async {
      Get.back();
      if (value == false) {
        msg = "서버 연결에 실패하였습니다.";
        error = true;
        update();
      } else {
        Map<String, dynamic> userMap = jsonDecode(value);
        var user = UserModel.fromJson(userMap);
        userName.value = user.personObj['name'].toString();
        print('전달할 유저 이름 : ${userName}');
        sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('name', user.personObj['name'].toString());
        String? pcode =  sharedPreferences.getString('pcode');
        String? sncode =  sharedPreferences.getString('sncode');
        print(pcode);
        print(sncode);
        Get.dialog(Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        if(pcode == null || sncode == null){
          register = false;
          print('등록 실패');
          update();
          refresh();
        }else if(pcode != null && sncode != null){
          register = true;
          print('등록 성공');
          update();
          refresh();
        }
        Get.offAll(() => home_view());

      }
    }

    );
  }


  sendCode (Barcode? result) {
    api.sendQRcode(result).then((value) async {
      if (value == false) {
        msg = "인증에 실패하였습니다.\n창을 닫은 후 다시 촬영해주세요.";
        error = true;
        Get.dialog(QuitWidget(serverMsg: msg));
        register = false;
        update();
      } else if (value == 'another') {
        print('다른거');
        Get.snackbar(
          '알림',
          '다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.',
          duration: Duration(seconds: 3),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
        register = false;
        qrcontroller!.dispose();
        update();
      } else {
        // model(value);
        print('리턴값 : ${value}');
        print(value['params']['pcode']);
        sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('pcode', value['params']['pcode']);
        sharedPreferences.setString('sncode', value['params']['sncode']);
        print(value);
        register = true;
        print('${register} : QR인증완료');
        update();
        refresh();
        qrcontroller!.dispose();
        Get.back();
      }
    });
  }

  void onQRViewCreated(QRViewController controller) {
    this.qrcontroller = controller;
    controller.scannedDataStream.listen((scanData) {
      if(scanData.code != null){
        this.qrcontroller?.pauseCamera();
        result = scanData;
        print(scanData.code);
        sendCode(result);
      }
    });
  }
  void onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('권한이 없습니다.')),
      );
    }
  }

  model(value) async {
    Map<String, dynamic> userMap = await jsonDecode(value);
    var user = UserModel.fromJson(userMap);
    print(user.personObj['name']);
    userName.value = user.personObj['name'].toString();
    update();
  }


  void initDialog(value) {
    Get.dialog(
        QuitWidget(serverMsg: msg)
    );
  }

  chk() async {
    sharedPreferences = await SharedPreferences.getInstance();
     id = sharedPreferences.getString('id');
     passwd = sharedPreferences.getString('passwd');
     print('chk');
  }

  final ImagePicker _picker = ImagePicker();
  File? image;
  Future getImage() async {
    final XFile? pickImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickImage != null){
      image = File(pickImage.path);
      final bytes = image?.readAsBytesSync();
      String base64Image =  "data:image/png;base64,"+base64Encode(bytes!);
      print(base64Image);
      update();
    }
  }


  static HomeViewModel get to => Get.find();


}