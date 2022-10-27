
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
  late SharedPreferences _sharedPreferences;
  String? id;
  String? passwd;
  RxString userName = ''.obs;
  String msg = '';
  bool error = false;
  int register = 0;

  Barcode? result;
  QRViewController? qrcontroller;


  final PageController pagecontroller = PageController(initialPage: 0, );
  StreamController sController = StreamController<int>()..add(0);

  void logoutProcess() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences.remove('token');
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
        // model(value);
        Map<String, dynamic> userMap = jsonDecode(value);
        var user = UserModel.fromJson(userMap);
        print(user.personObj['name']);
        userName.value = user.personObj['name'].toString();
        print('전달할 유저 이름 : ${userName}');
        _sharedPreferences = await SharedPreferences.getInstance();
        _sharedPreferences.setString('name', userName.value);
        print(value);
        if()

        update();
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
        register = 0;
        update();
      } else {
        // model(value);
        print('리턴값 : ${value}');
        print(value['params']['pcode']);
        _sharedPreferences = await SharedPreferences.getInstance();
        _sharedPreferences.setString('pcode', value['params']['pcode']);
        _sharedPreferences.setString('sncode', value['params']['sncode']);
        print(value);
        register = 1;
        update();
        refresh();
        print(register);
        Get.back();
      }
    });
  }

  void onQRViewCreated(QRViewController controller) {
    this.qrcontroller = controller;
    controller.scannedDataStream.listen((scanData) {
      if(scanData.code != null){
        this.qrcontroller?.dispose();
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
    _sharedPreferences = await SharedPreferences.getInstance();
     id = _sharedPreferences.getString('id');
     passwd = _sharedPreferences.getString('passwd');
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