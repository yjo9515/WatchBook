import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/notice_view.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:http/http.dart' as http;

class VideoController extends GetxController{
  var titleController = TextEditingController();
  var pickController = TextEditingController();
  var commentController = TextEditingController();

  DateTime? pickedDate;
  String comment = '';
  String title = '';
  int index = 0;

  ApiServices api = ApiServices();
  var listData;
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
    api.get('/SmartdoorVod/lists').then((value) {
      if(value.statusCode == 200) {
        listData = json.decode(value.body);
        print('요청한 리스트값 ${json.decode(value.body)}');
        // print(value[index]['title']);
        // print(value[index]['familyObj']);
        // json.decode(value).cast<Map<String, dynamic>>().toList();
        elements = [
          // type 0:게스트 키, 1:번호키, 2: 앱, 3:안면인식
          for(int i = 0; i < listData['lists'].length; i++)
            {'name': listData['lists'][i]['comment'],
              'group': DateFormat('yyyy-MM-dd').format(DateTime.parse(listData['lists'][i]['regDate'])),
              'filepath': listData['lists'][i]['filepath']
                  .replaceAll('/home/smartdoor','')
            },
        ];
        print(elements);
        update();
      } else if(value.statusCode == 401) {
        Get.offAll(login_view());
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
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
          utf8.decode(value.reasonPhrase!.codeUnits)
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
    // api.requestEntranceRead('/ProductSncodeVod/getList').then((value) async{
    //   if (value == false) {
    //     SnackBarWidget(serverMsg: value['message'],);
    //   } else {
    //     listData = value;
    //     print('요청한 리스트값 ${value}');
    //     // print(value[index]['title']);
    //     // print(value[index]['familyObj']);
    //         // json.decode(value).cast<Map<String, dynamic>>().toList();
    //     elements = [
    //       // type 0:게스트 키, 1:번호키, 2: 앱, 3:안면인식
    //       for(int i = 0; i < listData.length; i++)
    //         {'name': listData[i]['name'],
    //           'group': DateFormat('yyyy-MM-dd').format(DateTime.parse(listData[i]['startDate'])),
    //           'filepath': listData[i]['filepath'].replaceAll('/home/smartdoor','')
    //         },
    //     ];
    //     print(elements);
    //     update();
    //   }
    // });
    update();
  }

  void allUpdate() {

    update();
  }

}