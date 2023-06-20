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
import 'package:wisemonster/view/qna_detail_view.dart';
import 'package:wisemonster/view/qna_edit_view.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:http/http.dart' as http;

class Item {
  Item({
    required this.isExpanded,
    required this.id,
    required this.name,
    required this.answer,
  });
  bool isExpanded;
  var id;
  String name;
  String answer;
}

class QnaController extends GetxController{
  var titleController = TextEditingController();
  var commentController = TextEditingController();

  late List<Item> items;
  DateTime? pickedDate;
  String comment = '';
  String title = '';

  int index = 0;
  final isclear = false.obs;

  ApiServices api = ApiServices();
  var listData;
  List elements = [];
  @override
  void onInit() {

    requestEntrance();
    update();
    super.onInit();
  }

  List<Item> _generateItems(list) {
    return List.generate(
        list['lists'].length
        , (int index) {
      return Item(
        id: index,
        name: '${list['lists'][index]['title']}',
        isExpanded: false,
        answer: '${list['lists'][index]['memo']}',
      );
    });
  }

  ExpansionPanel buildExpansionPanel(Item item) {
    return ExpansionPanel(
        isExpanded: item.isExpanded,
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            title: Text(item.name),
            leading: IconButton(
                onPressed: (){
                Get.to(qna_detail_view(), arguments: item.id);
                  print(item.id);
            },
                iconSize: 10,
                icon: Icon(
                    Icons.chevron_right,
                size: 30,
                )),
          );
        },
        body:
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: item.answer.trim().isEmpty ?Text('답변을 기다리고있습니다.') : Text('${item.answer}'),
        )
    );
  }


  requestSend(){
    api.post(json.encode({
    'title':titleController.text.trim(),'comment':commentController.text.trim()
    }), '/Qna').then((value) {
      if(value.statusCode == 200) {
        Get.back();
        Get.snackbar(
          '알림',
          '등록되었습니다.'
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
        requestEntrance();
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
  }

  requestEntrance(){
    print('초기 인덱스');
    print(index);
    api.get('/Qna/lists').then((value) {
      if(value.statusCode == 200) {
        listData = json.decode(value.body);
        items = _generateItems(json.decode(value.body));
        print('요청한 리스트값 ${json.decode(value.body)}');
        isclear.value = true;
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
    update();
  }
  deleteQna(index){
    api.delete('/Qna/${listData['lists'][index]['qna_id']}').then((value) {
      if(value.statusCode == 200) {
        Get.back();
        requestEntrance();
        Get.snackbar(
          '알림',
          '삭제가 완료되었습니다.',
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
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
  }

  editQna(index){
    api.put(json.encode({'title':title,'comment':comment}),'/Qna/${listData['lists'][index]['qna_id']}').then((value) {
      if (value['result'] == false) {
        Get.snackbar(
          '알림',
          value['message'],
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }else{
        Get.back();
        requestEntrance();
        Get.snackbar(
          '알림',
          '수정이 완료되었습니다.',
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


  void allUpdate() {

    update();
  }

}