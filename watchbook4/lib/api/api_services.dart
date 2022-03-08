import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiServices extends GetxController {
  TextEditingController _id = TextEditingController();
  TextEditingController _passwd = TextEditingController();


  Future login(_id,_passwd) async{
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