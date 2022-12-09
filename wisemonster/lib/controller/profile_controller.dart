import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController{
  var nicknameController = TextEditingController();
  var tagController = TextEditingController();
  String nickname = '';
  String tag = '';
  ApiServices api = ApiServices();
  List? Tagdata;
  String readurl = ''; //리스트 값 얻을 서버 url 입력
  String deleteurl = '';
  String sendurl = '';
  var listData;

  final ImagePicker _picker = ImagePicker();
  File? image;
  String imageUrl = '';
  @override
  void onInit() async {

    requestTag();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString('nickname') != null){
      nickname =  sharedPreferences.getString('nickname')!;
      imageUrl = sharedPreferences.getString('pictureUrl')!;
    }
    update();
    super.onInit();
  }


  Future getImage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final XFile? pickImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickImage != null){
      image = File(pickImage.path);
      final bytes = image?.readAsBytesSync();
      String base64Image =  "data:image/png;base64,"+base64Encode(bytes!);
      print(base64Image);
      api.requestImageProcess('/Person/pictureProcess', base64Image).then((value){
        if (value['result'] == true) {
          Get.snackbar(
            '알림',
            '사진 등록이 완료되었습니다.'
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
          sharedPreferences.setString('pictureUrl', value['params']['pictureUrl']);
          imageUrl =  value['params']['pictureUrl'];
          print(value);
          update();
        }else{
          Get.snackbar(
            '알림',
            value['massage']
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        }
      });
      update();


    }
  }

  requestTag(){
    api.requestRead('/FamilyItem/getList').then((value) {
      if (value == false) {
        SnackBarWidget(serverMsg: value['message'],);
      } else {
        listData = value;
        update();
      }
    });
  }

  void sendNickname() {
    api.requestNickNameProcess(nicknameController.text.trim()).then((value) async {
      if (value['result'] == false) {
        SnackBarWidget(serverMsg: value['message'],);
      } else {
        print(value);
        if (value['result'] == true) {
          Get.offAll(profile_view());
          Get.snackbar(
            '알림',
            '닉네임이 변경되었습니다.'
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
          print('${value['params']['nickname']} 닉네임변경값');
          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          sharedPreferences.setString('nickname',value['params']['nickname']);
           nickname = value['params']['nickname'];
          update();
        } else {
          Get.snackbar(
            '알림',
            value['massage']
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
          update();
        }
        //user = UserModel.fromJson(value);
      }
    });
  }

  //소지품등록
  void sendTag() {
    api.requestTagProcess('/FamilyItem/saveAll',tagController.text).then((value) {
        print(value);
        if (value['result'] == true) {
          requestTag();
          Get.off(profile_view());
          Get.snackbar(
            '알림',
            '소지품 등록이 완료되었습니다.'
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
          update();
        } else {
          Get.back();
          Get.snackbar(
            '알림',
            value['message']
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
          update();
        }
        //user = UserModel.fromJson(value);

    });
  }

  //소지품삭제
  void deleteTag(index) {
    String familyScheduleId = listData[index]['family_item_id'];
    api.requestDeleteTag('/FamilyItem/deleteProcess',familyScheduleId).then((value) {
      if (value == false) {
        SnackBarWidget(serverMsg: value['message'],);
      } else {
        print(value);
        if (value['result'] == true) {
          requestTag();
          Get.offAll(profile_view());
            Get.snackbar(
              '알림',
              '소지품 삭제가 완료되었습니다.'
              ,
              duration: Duration(seconds: 5),
              backgroundColor: const Color.fromARGB(
                  255, 39, 161, 220),
              icon: Icon(Icons.info_outline, color: Colors.white),
              forwardAnimationCurve: Curves.easeOutBack,
              colorText: Colors.white,
            );
          update();
        } else {
          Get.snackbar(
            '알림',
            value['message']
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
          update();
        }
        //user = UserModel.fromJson(value);
      }
    });
  }
}