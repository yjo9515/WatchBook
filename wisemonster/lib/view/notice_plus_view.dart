import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/nickname_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../api/api_services.dart';
import '../controller/calendar_controller.dart';
import '../controller/camera_controller.dart';
import '../controller/notice_controller.dart';
import '../controller/profile_controller.dart';

class notice_plus_view extends GetView<NoticeController> {
  // Build UI
  String userName = '';
  ApiServices api = ApiServices();
  getName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userName = sharedPreferences.getString('name')!;
    print('회원이름 호출');
    print(userName);
    return await userName;
  }
  var con = Get.put(NoticeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NoticeController>(
        init: NoticeController(),
        builder: (NoticeController) => MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                    title: Text(
                      (Get.arguments == 'create')?
                      '공지 등록':'공지 수정',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 87, 132, 255),
                      ),
                    ),
                    automaticallyImplyLeading: true,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_outlined),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    actions: [
                      (Get.arguments == 'create')?
                      TextButton(
                          onPressed: () {
                            NoticeController.sendNotice(Get.arguments);
                          },
                          child: Text(
                            (Get.arguments == 'create')?
                            '등록':'완료',
                            style: TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 87, 132, 255),
                            ),
                          )) :
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                NoticeController.deleteNotice();
                              },
                              child: Text(
                                '삭제',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.red,
                                ),
                              )),
                          TextButton(
                              onPressed: () {
                                NoticeController.sendNotice(Get.arguments);
                              },
                              child: Text(
                                (Get.arguments == 'create')?
                                '등록':'완료',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 87, 132, 255),
                                ),
                              ))
                        ],
                      ),
                    ]),
                body: Container(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                  width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                  //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                  height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 50,
                  color: Colors.white,
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      H1(
                        changeValue: '글 제목',
                        size: 14,
                      ),
                      TextFieldWidget(
                        tcontroller:NoticeController.titleController,
                        changeValue: NoticeController.title,
                        hintText:
                        ( Get.arguments == 'create') ?
                        '제목을 입력해주세요.'
                            : '${controller.listData[controller.index]['title']}',
                      ),
                      Container(
                        height: 30,
                      ),
                      (Get.arguments == 'create')?  Container():
                      H1(
                        changeValue: '글쓴이',
                        size: 14,
                      ),
                      Container(
                        height: 20,
                      ),(Get.arguments == 'create')?Container(): Text(controller.listData[controller.index]['familyObj']['personObj']['nickname']),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '날짜',
                        size: 14,
                      ),
                      Container(
                        height: 20,
                      ),
                      (Get.arguments == 'create')?
                      Text('${DateTime.now().year}년 ${DateTime.now().month}월 ${DateTime.now().day}일') :
                      Text(DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(controller.listData[controller.index]['updateDate']))),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '내용',
                        size: 14,
                      ),
                      Container(
                        height: 20,
                      ),
                      TextField(
                          controller: NoticeController.commentController,
                          maxLines: 7, //or null
                          decoration: InputDecoration(
                            hintText: ( Get.arguments == 'create') ?
                            '내용을 입력해주세요.'
                                : '${controller.listData[controller.index]['comment']}',
                            hintStyle: TextStyle(fontSize: 17, color: Color.fromARGB(255, 222, 222, 222)),
                            enabledBorder:
                                OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 43, 43, 43))),
                          ),
                          onChanged: (value) {
                            //변화된 id값 감지
                            NoticeController.comment = value;
                          }),
                    ],
                  )),
                ),
              ),
            ));
  }
}
