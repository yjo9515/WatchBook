import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/nickname_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../api/api_services.dart';
import '../controller/calendar_controller.dart';
import '../controller/camera_controller.dart';
import '../controller/profile_controller.dart';

class calendar_plus_view extends GetView<CalendarController> {
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
  var con = Get.put(CalendarController());
  init(){
    print('초반');
    api.requestDateRead('/FamilySchedule/getListAtMonth',DateFormat('yyyy-MM-dd').format(DateTime.now())).then((value) {
      // if (value['result'] == false) {
      //   SnackBarWidget(serverMsg: '리스트를 불러올 수 없습니다',);
      // } else {
      con.detailData = json.decode(value).cast<Map<String, dynamic>>().toList();

      print(con.detailData);
      con.update();
      // }
    });

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarController>(
        init: CalendarController(),
        builder: (CalendarController) => MaterialApp(
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
                      '일정 등록':'일정 수정',
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
                              CalendarController.sendSchedule(Get.arguments);
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
                                CalendarController.deleteSchedule();
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
                                CalendarController.sendSchedule(Get.arguments);
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
                        changeValue: '일정 제목',
                        size: 14,
                      ),
                      TextFieldWidget(
                        tcontroller: CalendarController.titleController,
                        changeValue: CalendarController.title,
                        hintText: ( Get.arguments == 'create') ?'일정 제목을 입력해주세요.' : '${controller.detailData[controller.index]['name']}',
                      ),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '일정 시작일',
                        size: 14,
                      ),
                      TextField(
                        controller: CalendarController.startController, //editing controller of this TextField
                        decoration: InputDecoration(
                            icon: Icon(Icons.calendar_month_outlined), //icon of text field
                            labelText: Get.arguments == 'create'? "일정이 시작되는 날짜를 선택해주세요."
                          : '${DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(controller.detailData[controller.index]['startDate']))}'
                            ),
                        readOnly: true, //set it true, so that user will not able to edit text
                        onTap: () async {
                          CalendarController.pickedStartDate = (await showDatePicker(
                              initialEntryMode: DatePickerEntryMode.calendarOnly,
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2101)))!;
                          CalendarController.selectDate(0);
                        },
                      ),
                      TextField(
                        controller: CalendarController.startTimeController, //editing controller of this TextField
                        decoration: InputDecoration(
                            icon: Icon(Icons.timer), //icon of text field
                            labelText: Get.arguments == 'create'?"시작 시간을 선택해주세요." //label text of field
                                : '${DateFormat('HH시 mm분').format(DateTime.parse(controller.detailData[controller.index]['startDate']))}'
                        ),
                        readOnly: true, //set it true, so that user will not able to edit text
                        onTap: () async {
                          CalendarController.selectedStartTime =
                          (showTimePicker(context: context,
                              initialEntryMode: TimePickerEntryMode.inputOnly,
                              initialTime: TimeOfDay.now()))!;
                          CalendarController.selectedStartTime.then((timeOfDay) {
                            CalendarController.selectTime(0,timeOfDay);
                          }
                          );
                        },
                      ),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '일정 종료일',
                        size: 14,
                      ),
                      TextField(
                        controller: CalendarController.endController, //editing controller of this TextField
                        decoration: InputDecoration(
                            icon: Icon(Icons.calendar_month_outlined), //icon of text field
                            labelText:  Get.arguments == 'create'? "일정이 종료되는 날짜를 선택해주세요."
                          : '${DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(controller.detailData[controller.index]['stopDate']))}'//label text of field
                            ),
                        readOnly: true, //set it true, so that user will not able to edit text
                        onTap: () async {
                          CalendarController.pickedEndDate = (await showDatePicker(
                              initialEntryMode: DatePickerEntryMode.calendarOnly,
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2101)))!;
                          CalendarController.selectDate(1);
                        },
                      ),
                      TextField(
                        controller: CalendarController.endTimeController, //editing controller of this TextField
                        decoration: InputDecoration(
                            icon: Icon(Icons.timer), //icon of text field
                            labelText:  Get.arguments == 'create'?
                            "종료 시간을 선택해주세요." :'${DateFormat('HH시 mm분').format(DateTime.parse(controller.detailData[controller.index]['stopDate']))}'
                          //label text of field
                        ),
                        readOnly: true, //set it true, so that user will not able to edit text
                        onTap: () async {
                          CalendarController.selectedEndTime =
                          (showTimePicker(
                            initialEntryMode: TimePickerEntryMode.inputOnly,
                              context: context, initialTime: TimeOfDay.now()))!;
                          CalendarController.selectedEndTime.then((timeOfDay) {
                            CalendarController.selectTime(1,timeOfDay);
                          }
                          );
                        },
                      ),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '중요도',
                        size: 14,
                      ),
                      DropdownButton(
                        hint : Get.arguments == 'create'?Text('${CalendarController.selectValue}') :Text('${controller.detailData[controller.index]['level']}') ,
                        value: CalendarController.selectValue,
                          items: CalendarController.valueList.map(
                              (value){
                                return DropdownMenuItem(
                                     value: value,
                                    child: Text(value));
                              }
                          ).toList(),
                          onChanged: (value){
                          CalendarController.dropdown(value);
                      }),
                      Container(
                        height: 30,
                      ),

                      H1(
                        changeValue: '장소',
                        size: 14,
                      ),
                      TextFieldWidget(
                        tcontroller: CalendarController.placeController,
                        changeValue: CalendarController.place,
                        hintText:
                        Get.arguments == 'create' ?
                        '장소를 입력하세요.'
                           : controller.detailData[controller.index]['place'],
                      ),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '일정 내용',
                        size: 14,
                      ),
                      Container(
                        height: 20,
                      ),
                      TextField(
                          controller: CalendarController.valueController,
                          maxLines: 7, //or null
                          decoration: InputDecoration(
                            hintText:  Get.arguments == 'create' ?'일정 내용을 입력하세요.' : controller.detailData[controller.index]['comment'],
                            hintStyle: TextStyle(fontSize: 17, color: Color.fromARGB(255, 222, 222, 222)),
                            enabledBorder:
                                OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 43, 43, 43))),
                          ),
                          onChanged: (value) {
                            //변화된 id값 감지
                            CalendarController.comment = value;
                          }),
                    ],
                  )),
                ),
              ),
            ));
  }
}
