
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/login_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeViewModel extends GetxController{

  late SharedPreferences _sharedPreferences;

  void logoutProcess() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences.remove('token');
    print('로그아웃');
    Get.offAll(() => login_view());
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