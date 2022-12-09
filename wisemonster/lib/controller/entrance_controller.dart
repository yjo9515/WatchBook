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

class EntranceController extends GetxController{
  var titleController = TextEditingController();
  var pickController = TextEditingController();
  var commentController = TextEditingController();

  DateTime? pickedDate;
  String comment = '';
  String title = '';
  int index = 0;

  ApiServices api = ApiServices();
  List listData = [];
  List elements = [];
  @override
  void onInit() {

    requestEntrance();
    update();
    super.onInit();
  }


  requestEntrance(){
    print('초기 인덱스');
    print(index);
    api.requestEntranceRead('/ProductSncodeLog/getList').then((value) async{
      if (value == false) {
        SnackBarWidget(serverMsg: value['message'],);
      } else {
        listData = value;
        print('요청한 리스트값 ${value}');
        // print(value[index]['title']);
        // print(value[index]['familyObj']);
            // json.decode(value).cast<Map<String, dynamic>>().toList();
        elements = [
          // type 0:게스트 키, 1:번호키, 2: 앱, 3:안면인식
          {'name': listData[0]['personObj']['name'],
            'group': DateFormat('yyyy-MM-dd').format(DateTime.parse(listData[0]['personObj']['updateDate'])),
            'type': listData[0]['type']},
        ];
        print(elements);
        update();
      }
    });
    update();
  }

  void allUpdate(value) {
    index = value;
    print('${index} 인덱스값');
    update();
  }

}