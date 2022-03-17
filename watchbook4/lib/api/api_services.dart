import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServices extends GetxController {

  Future loginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? tokenValue = sharedPreferences.getString('token');
    update();
    //저장된 토큰값 가져오기
    print("토큰값 : ${tokenValue}");
    if (tokenValue != null) { //사용자 정보 전송
      String apiurl = 'https://www.watchbook.tv/test';
      var response = await http.post(Uri.parse(apiurl),
          headers: {HttpHeaders.authorizationHeader: "Bearer ${tokenValue}"}
      );
      print(response.headers);
      print(response.body);
    }
    return tokenValue;
  }

  Future requestSendAuthProcess(_phone) async {
    var timer = 300;//인증만료 시간 설정
    String apiurl = 'https://www.watchbook.tv/User/sendSmsAuthProcess?name=${name}&handphone=${_phone}&expire=${timer}';

  }

  Future login(_id, _passwd) async {
    Get.dialog(Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    String apiurl = 'https://www.watchbook.tv/User/getToken'; //토큰요청
    print(_id);
    print(_passwd);
    var response = await http.post(Uri.parse(apiurl),
        body: {
          'id': _id.text.trim(), //get the id text
          'passwd': _passwd.text.trim() //get passwd text
        }
    );
    if (response.statusCode == 200) {
      //정상신호 일때
      print(response.body);
      Map<String, dynamic> jsondata = json.decode(response.body);

      return jsondata;
    } else {
      return false;
    }
  }

  Future findId(_name, _phone) async {
    Get.dialog(Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    String apiurl = 'https://www.watchbook.tv/User/watchbookfindIdProcess'; //토큰요청
    print(_name);
    print(_phone);
    var response = await http.post(Uri.parse(apiurl),
        body: {
          'name': _name.text.trim(),
          'handphone': _phone.text.trim(),
          'type' : 'handphone'
        }
    );
    if (response.statusCode == 200) {
      //정상신호 일때
      print(response.body);
      Map<String, dynamic> jsondata = json.decode(response.body);
      return jsondata;
    } else {
      return false;
    }
  }

  Future findPw(_id, _phone) async {
    Get.dialog(Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    String apiurl = 'https://www.watchbook.tv/User/watchbookfindPasswdProcess'; //토큰요청
    print(_id);
    print(_phone);
    var response = await http.post(Uri.parse(apiurl),
        body: {
          'id': _id.text.trim(),
          'handphone': _phone.text.trim(),
          'type' : 'handphone'
        }
    );
    if (response.statusCode == 200) {
      //정상신호 일때
      print(response.body);
      Map<String, dynamic> jsondata = json.decode(response.body);
      return jsondata;
    } else {
      return false;
    }
  }


  imagePush() async{
    String apiurl = 'https://www.watchbook.tv/User/getToken';
    var response = await http.post(Uri.parse(apiurl),
        body: {

        }
    );
  }
}
