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
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:http/http.dart' as http;

import '../models/mqtt.dart';

class NoticeController extends GetxController{
  var titleController = TextEditingController();
  var pickController = TextEditingController();
  var commentController = TextEditingController();
  var home = Get.put(HomeViewModel());

  DateTime? pickedDate;
  String comment = '';
  String title = '';

  final isclear = false.obs;

  ApiServices api = ApiServices();
  late final listData = [].obs;
  Mqtt mqtt = new Mqtt();
  @override
  void onInit() {
    requestNotice();
    update();
    super.onInit();
  }
  requestNotice(){
    print('초기 인덱스');
    print(Get.arguments);
    api.requestNoticeRead('/FamilyNotice/getList').then((value){
      if (value == false) {
        SnackBarWidget(serverMsg: value['message'],);
      } else {
        listData.value = value;
        print(listData.length);
        print('요청한 리스트값 ${value}');
        // print(value[index]['title']);
        // print(value[index]['familyObj']);
            // json.decode(value).cast<Map<String, dynamic>>().toList();
        update();
        isclear.value = true;
      }
    });
    update();
  }
  deleteNotice(index)  {
    String? familyScheduleId = listData[index!]['family_notice_id'];
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
        isclear.value = false;
        requestNotice();
        Get.back();
        // Get.offAll(notice_view());
        refreshDoorUi();
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
  void sendNotice(argument,index) async{
    // if(index == null){
    //   index = 0;
    //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //   sharedPreferences.setString('family_notice_id', listData[index]['family_notice_id']);
    //   update();
    // }
    String? familyNoticeId;
    if(argument != 'create'){
      familyNoticeId = listData[index!]['family_notice_id'];
    }else{
      familyNoticeId = '0';
    }

    api.requestNoticeProcess(titleController.text.trim(),
      comment,argument,familyNoticeId
    ).then((value) async {
        print(value);
        if (value['result'] == true) {
          refresh();
          refreshDoorUi();
          requestNotice();
          titleController.clear();
          commentController.clear();
          // Get.offAll(notice_view());
          Get.back();
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
        } else {
          Get.snackbar(
            '알림',
            value['message'].toString()
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
  refreshDoorUi(){
    if(mqtt.client?.connectionStatus?.state == MqttConnectionState.disconnected){
      // home.connect();
      print('커넥시도');
    }
    String? sncode =  home.sharedPreferences.getString('sncode');
    String topic = 'smartdoor/SMARTDOOR/${sncode}';
    var builder = MqttClientPayloadBuilder();
    builder.addString('{"request":"refresh"}');
    mqtt.client?.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

}