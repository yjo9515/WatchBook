
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/models/user_model.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/widgets/InitialWidget.dart';
import '../view/login_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeViewModel extends GetxController{
  ApiServices api = ApiServices();
  late SharedPreferences _sharedPreferences;
  String? id;
  String? passwd;
  late UserModel user;
  String msg = '';
  bool error = false;

  void logoutProcess() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences.remove('token');
    print('로그아웃');
    Get.offAll(() => login_view());
  }
  void info() {
    api.getInfo().then((value) {
      Get.back();
      if (value == false) {
        msg = "서버 연결에 실패하였습니다.";
        error = true;
        update();
      } else {
        print(value);
        Get.offAll(() => home_view());
        update();
        //user = UserModel.fromJson(value);
      }
    });
  }

  void initDialog(value) {
    Get.dialog(
        InitialWidget(serverMsg: msg)
    );
  }

  chk() async {
    _sharedPreferences = await SharedPreferences.getInstance();
     id = _sharedPreferences.getString('id');
     passwd = _sharedPreferences.getString('passwd');
     print('chk');
  }

  final ImagePicker _picker = ImagePicker();
  var image;
  Future getImage() async {
    final XFile? pickImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickImage != null){
      image = File(pickImage.path);
      final bytes = image.readAsBytesSync();
      String base64Image =  "data:image/png;base64,"+base64Encode(bytes);
      print(base64Image);
      update();
    }
  }

}