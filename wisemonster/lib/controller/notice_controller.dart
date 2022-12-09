import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/notice_view.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:http/http.dart' as http;

class NoticeController extends GetxController{
  var titleController = TextEditingController();
  var pickController = TextEditingController();
  var commentController = TextEditingController();

  DateTime? pickedDate;
  String comment = '';
  String title = '';
  int index = 0;

  ApiServices api = ApiServices();
  List listData = [];

  @override
  void onInit() {

    requestNotice();
    update();
    super.onInit();
  }
  requestNotice(){
    print('초기 인덱스');
    print(index);
    api.requestNoticeRead('/FamilyNotice/getList').then((value) async{
      if (value == false) {
        SnackBarWidget(serverMsg: value['message'],);
      } else {
        listData = value;
        print('요청한 리스트값 ${value}');
        // print(value[index]['title']);
        // print(value[index]['familyObj']);
            // json.decode(value).cast<Map<String, dynamic>>().toList();
        update();
      }
    });
    update();
  }
  deleteNotice()  {
    String? familyScheduleId = listData[index]['family_notice_id'];
    print('${familyScheduleId} : family_notice_id');
    api.requestNoticeDelete('/FamilyNotice/deleteProcess',familyScheduleId).then((value) {
      if (value['result'] == false) {
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
      } else {
        Get.back();
        refresh();
        requestNotice();
        Get.snackbar(
          '알림',
          '완료되었습니다.'
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

  }
  void sendNotice(argument) async{
    if(index == null){
      index = 0;
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('family_notice_id', listData[index]['family_notice_id']);
      update();
    }
    api.requestNoticeProcess(titleController.text.trim(),
      comment,argument
    ).then((value) async {

        print(value);
        if (value['result'] == true) {
          refresh();
          Get.back();
          requestNotice();
          Get.snackbar(
            '알림',
            '완료되었습니다.'
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
          refresh();
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
    });
  }

  void allUpdate(value) {
    index = value;
    print('${index} 인덱스값');
    update();
  }

}