import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisemonster/view/widgets/CalendarWidget.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/LeftSlideWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import '../controller/calendar_controller.dart';
import 'dart:io' as i;

import 'key_view.dart';

class calendar_view extends GetView<CalendarController> {
  HomeViewModel HomeViewModel2 = HomeViewModel();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarController>(
        init: CalendarController(),
        builder: (controller) =>
            Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                actions: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      children: [
                        Text('캘린더',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 87, 132, 255),
                            )),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.account_circle, size: 19, color: Color.fromARGB(255, 255, 255, 255)),
                        )
                      ],
                    ),
                  )
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
                    Obx(() => TableCalendar(
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
                        controller.focus();
                        print('포커스');
                      },
                    )),
                    Container(
                      margin: EdgeInsets.fromLTRB(16, 20, 16, 20),
                      height: 1,
                      color: Color.fromARGB(255, 204, 204, 204),
                    ),
                    Container(
                      child: SingleChildScrollView(
                          child:Column(
                            children: [
                              H1(changeValue: '12일', size: 14,),


                            ],
                          )
                      ),
                    )
                  ],
                ),
              ),
                drawer: LeftSlideWidget(),
            )

    );
  }
}