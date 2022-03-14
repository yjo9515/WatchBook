import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServices extends GetxController {

  loginStatus(tokenValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    late String? tokenValue = sharedPreferences.getString('token');
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
}
