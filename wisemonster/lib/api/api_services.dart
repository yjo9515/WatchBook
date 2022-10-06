import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/models/user_model.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';

class ApiServices extends GetxController {
  var authresponse;
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

  Future requestSendAuthProcess(phoneController,nameController) async {

    var timer = 300;//인증만료 시간 설정
    String apiurl = 'https://www.watchbook.tv/User/sendSmsAuthProcess?name=${nameController.text.trim()}&handphone=${phoneController.text.trim()}&expire=${timer}';

    authresponse = await http.post(Uri.parse(apiurl),
        body: {
          'handphone': phoneController.text.trim(), //번호 가져오기
        }
    );
    if (authresponse.statusCode == 200) {
      //정상신호 일때
      print(nameController.text.trim());
      print(phoneController.text.trim());
      print(authresponse.body);

      Map<String, dynamic> jsondata = json.decode(authresponse.body);
      return jsondata;
    } else {
      return false;
    }
  }

  requestCheckName(nameController) async{
    String url = 'https://www.watchbook.tv/User/watchbooknameCheck';
    var response = await http.post(Uri.parse(url),
        body:{
          'name' : nameController.text.trim()
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      return jsondata;
    }else{
      return false;
    }
  }

  requestCheckAuthProcess(phoneAuthController) async{
    Map<String, dynamic> jsondata = json.decode(authresponse.body);

    if (authresponse.statusCode == 200) {
      return jsondata;
    }else{
      return false;
    }
  }

  requestSearchId(idController) async{
    String url = 'https://www.watchbook.tv/User/watchbooksearchId?id=${idController.text.trim()}';
    var response = await http.post(Uri.parse(url),
        body:{
          'id' : idController.text.trim()
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      return jsondata;
    }else{
      return false;
    }
  }

  requestSearchNickname(nicknameController) async{
    String url = 'https://www.watchbook.tv/Person/searchNickname?nickname=${nicknameController.text.trim()}';
    var response = await http.post(Uri.parse(url),
        body:{
          'nickname' : nicknameController.text.trim()
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      return jsondata;
    }else{
      return false;
    }
  }

  requestJoinProcess(all) async{
    String url = 'https://www.watchbook.tv/User/watchbookjoinProcess';
    var response = await http.post(Uri.parse(url),
        body:{
          // 'type' : all[0],
          'id' : all[0],
          'passwd' : all[1],
          'repasswd' : all[2],
          'name' : all[3],
          // 'handphone': all[6],
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      return jsondata;
    }else{
      return false;
    }
  }

  Future login(_id, _passwd) async {
    Get.dialog(Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    String apiurl = 'https://www.watchbook.tv/User/getToken'; //토큰요청
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

  Future getInfo() async {
    Get.dialog(Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? id = sharedPreferences.getString('id');
    String? passwd = sharedPreferences.getString('passwd');
    String? tokenValue = sharedPreferences.getString('token');
    print(id);
    print(passwd);
    String apiurl = 'https://www.watchbook.tv/User/getInfo'; //토큰요청
    var response = await http.post(Uri.parse(apiurl),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${tokenValue}"}//넣어야 로그인 인증댐
    );
    if (response.statusCode == 200) {
      //정상신호 일때
      print(response.body);

      return UserModel.fromJson(json.decode(response.body));
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
