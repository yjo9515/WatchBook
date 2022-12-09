import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisemonster/view/widgets/CalendarWidget.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/LeftSlideWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import '../controller/calendar_controller.dart';
import 'dart:io' as i;

import 'calendar_plus_view.dart';
import 'key_view.dart';

class calendar_view extends GetView<CalendarController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarController>(
        init: CalendarController(),
        builder: (controller) =>
            WillPopScope(
                onWillPop: () => _goBack(context),
            child:
            Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                centerTitle: true,
                title: Text(
                  '캘린더',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 87, 132, 255),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: (){
                        Get.to(calendar_plus_view(),arguments: 'create');
                      },
                      child: Text(
                        '추가',
                        style: TextStyle(
                          fontSize: 17,
                          color: Color.fromARGB(255, 87, 132, 255),
                        ),
                      ))
                ],
              ),
              body: Container(
                width: MediaQueryData
                    .fromWindow(WidgetsBinding.instance!.window)
                    .size
                    .width,
                height: MediaQueryData
                    .fromWindow(WidgetsBinding.instance!.window)
                    .size
                    .height,
                child: Column(
                  children: [
                    // CalendarWidget(),
                    Container(height: 30,),
                    Expanded(
                      flex: 30,
                        child: Obx(() => TableCalendar(
                          // eventLoader: controller.roadEvent,
                      focusedDay: controller.focusedDay.value,
                      firstDay: DateTime(2022,10,1),
                      lastDay: DateTime(2030,10,31),
                      locale: 'ko-KR',
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
                        // tableBorder: TableBorder(
                        //   bottom: BorderSide(color: Color.fromARGB(255, 204, 204, 204)),
                        // ),
                          markerSize: 10.0,
                          markerDecoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle
                          ),
                          outsideDaysVisible: false,
                          todayDecoration: BoxDecoration(
                            color: Color.fromARGB(255, 18, 136, 248),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          )),
                      onDaySelected: (var selectedDay2,var focusedDay2) {
                        controller.selected(selectedDay2, focusedDay2);
                      },
                      selectedDayPredicate: (day) {
                        // selectedDay 와 동일한 날짜의 모양을 바꿔줍니다.
                        return isSameDay(controller.selectedDay.value, day);

                      },
                      onFormatChanged: (format){
                        if(controller.calendarFormat != format){
                          controller.calendarFormat = format.obs;
                        }
                      },
                      onPageChanged: (focusedDay) {
                        // No need to call `setState()` here
                        controller.focus(focusedDay);
                        print('포커스');
                      },
                    ))),

                    Container(
                      margin: EdgeInsets.fromLTRB(16, 20, 16, 20),
                      height: 1,
                      color: Color.fromARGB(255, 204, 204, 204),
                    ),
                    Expanded(
                      flex: 25,
                          child:Column(

                            children: [
                              H1(changeValue: '${DateFormat('dd').format(controller.selectedDay.value)}일', size: 17,),
                              Container(height: 20,),
                              Expanded(
                                flex: 1,
                                child: ListView.builder(
                                  itemCount:
                                  controller.detailData == null ? 0 : controller.detailData?.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Card(
                                      margin: EdgeInsets.fromLTRB(16, 5, 16, 5),
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      child:
                                      // new Text(ProfileController.Tagdata![1]),
                                      ListTile(
                                        contentPadding: EdgeInsets.only(right: 10 ),
                                        leading: Container(
                                          width: 6,
                                          color: Colors.red,
                                        ),
                                        title: Text(controller.detailData[index]['name']),
                                        onTap: (){
                                            controller.index = index;
                                            controller.allUpdate();
                                            controller.update();
                                            Get.to(calendar_plus_view(),arguments: 'edit');
                                        },
                                      )
                                    );
                                  },
                                ),
                              ),
                              Container(height: 58,),
                            ],
                          )
                      ),
                  ],
                ),
              ),
                drawer: LeftSlideWidget(),
            ))

    );
  }
  Future<bool> _goBack(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱을 종료하시겠어요?'),
        actions: <Widget>[
          TextButton(
            child: const Text('네'),
            onPressed: () => Navigator.pop(context, true),
          ),
          TextButton(
            child: const Text('아니오'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}