import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/models/user_model.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ApiServices extends GetxController {
  var authresponse;

  String sever = 'https://www.smartdoor.watchbook.tv';
  Future loginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? tokenValue = sharedPreferences.getString('token');
    update();
    //저장된 토큰값 가져오기
    print("토큰값 : ${tokenValue}");
    if (tokenValue != null) { //사용자 정보 전송
      String apiurl = '${sever}/test';
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
    String apiurl = '${sever}/User/sendSmsAuthProcess?name=${nameController.text.trim()}&handphone=${phoneController.text.trim()}&expire=${timer}';

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
    String url = '${sever}/User/watchbooknameCheck';
    var response = await http.post(Uri.parse(url),
        body:{
          'name' : nameController.text.trim()
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      return json.decode(response.body);
    }else{
      return false;
    }
  }

  // requestCheckAuthProcess(phoneAuthController) async{
  //   Map<String, dynamic> jsondata = json.decode(authresponse.body);
  //
  //   if (authresponse.statusCode == 200) {
  //     return json.decode(response.body);
  //   }else{
  //     return false;
  //   }
  // }

  requestSearchId(idController) async{
    String url = '${sever}/User/watchbooksearchId?id=${idController.text.trim()}';
    var response = await http.post(Uri.parse(url),
        body:{
          'id' : idController.text.trim()
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      return json.decode(response.body);
    }else{
      return false;
    }
  }

  requestSearchNickname(nicknameController) async{
    String url = '${sever}/Person/searchNickname?nickname=${nicknameController.text.trim()}';
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
    String url = '${sever}/User/watchbookjoinProcess';
    var response = await http.post(Uri.parse(url),
        body:{
          // 'type' : all[0],
          'id' : all[0],
          'passwd' : all[1],
          'repasswd' : all[2],
          'name' : all[3],
          'handphone': all[4],
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

  requestPlaceJoinProcess(sncode,place) async{
    String url = '${sever}/ProductSncodeFamily/updateProcess';
    var response = await http.post(Uri.parse(url),
        body:{
          'place' : place.toString(),
          'product_sncode_id' : sncode.toString(),
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      // Map<String, dynamic> jsondata = json.decode(response.body);
      return json.decode(response.body);
    }else{
      return false;
    }
  }

  requestNickNameProcess(nicknameController) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? personId = sharedPreferences.getString('person_id');
    String url = '${sever}/Person/saveAll';

    var response = await http.post(Uri.parse(url),
        body:{
          'nickname' : nicknameController,
          'person_id' : personId
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

  //소지품전송
  requestTagProcess(route,tag) async{
    String url = '${sever+route}';
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(url),
        body:{
           'family_item_id':sharedPreferences.getString('family_item_id').toString(),
           'family_person_id':sharedPreferences.getString('family_person_id').toString(),
          'name' : tag,
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

  //읽기
  requestRead(route) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${sever+route}';
    var response = await http.post(Uri.parse(url),
        body:{
          'family_person_id':sharedPreferences.getString('family_person_id').toString(),
          'isAll' : '1'
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> jsondata = json.decode(response.body);
      return jsondata;
    }else{
      return false;
    }
  }


  //사진
  requestImageProcess(route,base64Image) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${sever+route}';
    var response = await http.post(Uri.parse(url),
        body: {
          'picture[data]': base64Image,
          'person_id' : sharedPreferences.getString('person_id'),
          'isDelPicture' : '1',
          'resultType' : 'json'
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

  requestFaceProcess(route,base64Image) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${sever+route}';
    var response = await http.post(Uri.parse(url),
        body: {
          'face[data]': base64Image,
          'person_id' : sharedPreferences.getString('person_id'),
          'resultType' : 'json'
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

  requestDateRead(route,date) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    String? familyId = sharedPreferences.getString('family_id');
    String? familyPersonId = sharedPreferences.getString('family_person_id');
    String url = '${sever+route}';
    var response = await http.post(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${token}"},
        body:{
          'family_id' : familyId,
          'family_person_id' : familyPersonId,
          'startDate' : date.toString(),
          'stopDate' : date.toString(),
        }
    );
    // print(response.body);

    if (response.statusCode == 200) {

      List<dynamic> jsondata = json.decode(response.body);
      return jsondata;
    }else{
      return false;
    }
  }

  requestSchedule(addurl,title,startDate,stopDate,level,place,comment,argument) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    String? familyId = sharedPreferences.getString('family_id');
    String? familyPersonId = sharedPreferences.getString('family_person_id');
    String? familyScheduleId = sharedPreferences.getString('family_schedule_id');
    print(addurl);
    print(title);
    print(startDate);
    print(stopDate);
    print(level);
    print(place);
    print(comment);



    String url = '${sever+addurl}';
    print(url);
    print(token);
    print(familyId);
    print(familyPersonId);
    if(argument == 'create'){
    var response = await http.post(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${token}"},
        body:{
          'family_id' : familyId,
          'family_person_id' : familyPersonId,
          'name' : title,
          'startDate' : startDate,
          'stopDate' : stopDate,
          'level' : level,
          'place': place,
          'comment' : comment
        }
    );
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      return jsondata;
    }else{
      return false;
    }
    }else{
      print(familyScheduleId);
      var response = await http.post(Uri.parse(url),
          headers: {HttpHeaders.authorizationHeader: "Bearer ${token}"},
          body:{
            'family_schedule_id' : familyScheduleId,
            'family_id' : familyId,
            'family_person_id' : familyPersonId,
            'name' : title,
            'startDate' : startDate,
            'stopDate' : stopDate,
            'level' : level,
            'data[place]': place,
            'comment' : comment
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


  }

  getKey(startDate,endDate,pw,phone) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${sever}/ProductSncode/guestkeyJoinProcess';
    print(sharedPreferences.getString('family_id').toString());
    print(sharedPreferences.getString('person_id').toString());
    print(startDate);
    print(endDate);
    var response = await http.post(Uri.parse(url),
        body:{
          'product_sncode_id' :sharedPreferences.getString('product_sncode_id').toString(),
          'family_id' : sharedPreferences.getString('family_id').toString(),
          'person_id' : sharedPreferences.getString('person_id').toString(),
          'startDate' : startDate,
          'stopDate' : endDate,
          'passwd' : pw,
          'handphone' : phone,
          'resultType' : 'json'
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

  requestDelete(route,familyScheduleId) async{
    String url = '${sever+route}';
    var response = await http.post(Uri.parse(url),
        body:{
          'family_schedule_id' : familyScheduleId,
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

  requestFaceDelete(route) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${sever+route}';
    var response = await http.post(Uri.parse(url),
        body:{
          'person_id' : sharedPreferences.getString('person_id'),
          'resultType' : 'json'
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

  requestNoticeDelete(route,familyScheduleId) async{
    String url = '${sever+route}';
    var response = await http.post(Uri.parse(url),
        body:{
          'family_notice_id' : familyScheduleId,
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

  requestDeleteTag(route,familyScheduleId) async{
    String url = '${sever+route}';
    var response = await http.post(Uri.parse(url),
        body:{
          'family_item_id' : familyScheduleId,
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
    String apiurl = '${sever}/User/getToken'; //토큰요청
    var response = await http.post(Uri.parse(apiurl),
        body: {
          'id': _id.text.trim(), //get the id text
          'passwd': _passwd.text.trim() //get passwd text
        }
    );
    if (response.statusCode == 200) {
      //정상신호 일때
      print(response.headers);
      print(response.body);
      Map<String, dynamic> jsondata = json.decode(response.body);
      print('${jsondata} : 로그인쪽 ');
      return jsondata;
    } else {
      return false;
    }
  }

  Future findId(_name, _phone) async {
    Get.dialog(Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    String apiurl = '${sever}/User/findIdProcess'; //토큰요청
    print(_name);
    print(_phone);
    var response = await http.post(Uri.parse(apiurl),
        body: {
          'name': _name,
          'handphone': _phone,
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
    String apiurl = '${sever}/User/watchbookfindPasswdProcess'; //토큰요청
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
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? id = sharedPreferences.getString('id');
    String? tokenValue = sharedPreferences.getString('token');
    print(id);
    String apiurl = '${sever}/User/getInfoAtFamily'; //토큰요청
    var response = await http.post(Uri.parse(apiurl),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${tokenValue}"}//넣어야 로그인 인증댐
    );
    if (response.statusCode == 200) {
      //정상신호 일때
      print('${response.body} : 유저정보');
      UserModel.fromJson(json.decode(response.body));
      return json.decode(response.body);
    } else {
      return false;
    }
  }
  sendQRcode(code) async {
    String another = 'another';
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    if(code.code.contains("|")){
      var scode = code.code.split('|');
      print('${scode[0]} : 코드');
      print('${scode[1]} : 코드');
      print(token);
      String url = '${sever}/ProductSncodeFamily/joinProcess?pcode=${scode[0]}&sncode=${scode[1]}&token=${token}&resultType=json';
      print(url);

      var response = await http.get(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${token.toString()}"},
      );
      print('${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsondata = json.decode(response.body);
        return jsondata;
      }else{
        return false;
      }
    } else {
      Get.back();

      return another;
    }

  }

  //공지 등록
  requestNoticeProcess(title,comment,argument,familyNoticeId) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    String? familyId = sharedPreferences.getString('family_id');
    String? personId = sharedPreferences.getString('person_id');
    print(familyId);
    print(personId);
    print(title);
    print(comment);
    if(argument == 'create'){
      print('생성');
      String url = '${sever}/FamilyNotice/joinProcess';
      var response = await http.post(Uri.parse(url),
          headers: {HttpHeaders.authorizationHeader: "Bearer ${token}"},
          body:{
            'family_id' : familyId,
            'person_id' : personId,
            'title' : title,
            'comment' : comment
          }
      );
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsondata = json.decode(response.body);
        return json.decode(response.body);
      }else{
        return false;
      }
    }else {
      print('수정');
      print(familyNoticeId);
      String url = '${sever}/FamilyNotice/JoinProcess';
      var response = await http.post(Uri.parse(url),
          headers: {HttpHeaders.authorizationHeader: "Bearer ${token}"},
          body:{
            'family_notice_id' : familyNoticeId,
            'family_id' : familyId,
            'person_id' : personId,
            'title' : title,
            'comment' : comment
          }
      );
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsondata = json.decode(response.body);
        return json.decode(response.body);
      }else{
        return false;
      }
    }

  }

  requestNoticeRead(route) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${sever+route}';
    var response = await http.post(Uri.parse(url),
        body:{
          'family_id':sharedPreferences.getString('family_id').toString(),
          'isAll' : '1',
          'rowsPerPage' : '4'
        }
    );
    print(sharedPreferences.getString('family_id').toString());
    print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> jsondata = json.decode(response.body);
      return jsondata;
    }else{
      return false;
    }
  }

  doorControl(con) async {
    String apiurl = '${sever+con}';
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(apiurl),
        body: {
          'product_sncode_id':sharedPreferences.getString('product_sncode_id').toString(),
          'person_id':sharedPreferences.getString('person_id').toString(),
          'family_id':sharedPreferences.getString('family_id').toString(),
          'resultType':'json'
        }
    );
    print(response.body);

    if (response.statusCode == 200) {

      return  json.decode(response.body);;
    }else{
      return false;
    }
  }

  imagePush() async{
    String apiurl = '${sever}/User/getToken';
    var response = await http.post(Uri.parse(apiurl),
        body: {

        }
    );
  }

  //읽기
  requestEntranceRead(route) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${sever+route}';
    var response = await http.post(Uri.parse(url),
        body:{
          'family_id':sharedPreferences.getString('family_id').toString(),
          'typeValue':'nickname',
          'rowsPerPage' : '4'
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> jsondata = json.decode(response.body);
      return json.decode(response.body);
    }else{
      return false;
    }
  }

  sendFcmToken(route) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = await FirebaseMessaging.instance.getToken();
    String url = '${sever+route}';
    print('토큰 ${token}');
    var response = await http.post(Uri.parse(url),
        body:{
          'person_id':sharedPreferences.getString('person_id').toString(),
          'token':token.toString(),
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      // List<dynamic> jsondata = json.decode(response.body);
      return jsonDecode(response.body);
    }else{
      return false;
    }
  }

  requestRTCToken(route,random) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${sever+route}';
    String? sncode =  sharedPreferences.getString('scode');
    print(random);
    var response = await http.post(Uri.parse(url),
        body:{
          'channelName': random,
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      // List<dynamic> jsondata = json.decode(response.body);
      //jsonDecode(response.body)
      return json.decode(response.body);
    }else{
      return false;
    }
  }

  requestRTCinit(agoratokenid) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? sncode =  sharedPreferences.getString('scode');
    String url = '${sever}/AgoraToken/sendMqtt';
    var response = await http.post(Uri.parse(url),
        body:{
          'family_id' : sharedPreferences.getString('family_id').toString(),
          'person_id' : sharedPreferences.getString('person_id'),
          'agora_token_id': agoratokenid.toString(),
          'topic': 'smartdoor/SMARTDOOR/${sncode}',
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }else{
      return false;
    }
  }

  //읽기
  requestConfigRead(route) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${sever+route}';
    print('${sharedPreferences.getString('product_sncode_id').toString()} product_sncode_id');

    var response = await http.post(Uri.parse(url),
        body:{
          'product_sncode_id':sharedPreferences.getString('product_sncode_id').toString(),
          'family_id' : sharedPreferences.getString('family_id').toString()
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      // List<dynamic> jsondata = json.decode(response.body);
      return jsonDecode(response.body);
    }else{
      return false;
    }
  }

  requestConfigSend(route,type,toggle) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${sever+route}';
    print('${sharedPreferences.getString('product_sncode_id').toString()} product_sncode_id');
    String? toggleValue;
    if(toggle == true){
      toggleValue = '1';
    } else {
      toggleValue = '0';
    }

    var response;
    if(type == 'isDoorbell'){
     response = await http.post(Uri.parse(url),
        body:{
          'isDoorbell': toggleValue,
          'product_sncode_id':sharedPreferences.getString('product_sncode_id').toString(),
        }
    );
    print(response.body);
    }else if(type == 'isAccessRecord'){
       response = await http.post(Uri.parse(url),
      body:{
        'isAccessRecord': toggleValue,
        'product_sncode_id':sharedPreferences.getString('product_sncode_id').toString(),
    }
      );
      print(response.body);
    }else if(type == 'isMotionDetect'){
       response = await http.post(Uri.parse(url),
          body:{
            'isMotionDetect': toggleValue,
            'product_sncode_id':sharedPreferences.getString('product_sncode_id').toString(),
          }
      );
      print(response.body);
    }


    if (response.statusCode == 200) {
      // List<dynamic> jsondata = json.decode(response.body);
      return jsonDecode(response.body);
    }else{
      return false;
    }
  }

  requestDoorRead(route) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${sever+route}';
    print('${sharedPreferences.getString('product_sncode_id').toString()} product_sncode_id');

    var response = await http.post(Uri.parse(url),
        body:{
          'product_sncode_id':sharedPreferences.getString('product_sncode_id').toString(),
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      // List<dynamic> jsondata = json.decode(response.body);
      return jsonDecode(response.body);
    }else{
      return false;
    }
  }
}
