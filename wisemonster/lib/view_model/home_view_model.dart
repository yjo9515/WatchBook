
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
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
  String? userName2;
  RxInt selectedIndex = 2.obs;
  String msg = '';
  bool error = false;


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
        userName2 = user.personObj['name'].toString();
        print(userName);
        print('${userName2} 제바바ㅏ발');
        _sharedPreferences = await SharedPreferences.getInstance();
        _sharedPreferences.setString('name', userName.value);
        print(value);
        update();
        Get.offAll(() => home_view(), arguments: userName);

      }
    }

    );
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


  void changeIndex(int index) {
    selectedIndex(index);
    print(index);

  }

}