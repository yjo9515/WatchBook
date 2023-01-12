
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisemonster/view/calendar_view.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../api/api_services.dart';
import '../models/mqtt.dart';
import '../view/widgets/SnackBarWidget.dart';
import 'package:intl/intl.dart';

class CalendarController extends GetxController{
  ApiServices api = ApiServices();

  String readurl = '/FamilySchedule/getList'; //리스트 값 얻을 서버 url 입력
  List detailData = [];
  var titleController = TextEditingController();
  var startController = TextEditingController();
  var endController = TextEditingController();
  var startTimeController = TextEditingController();
  var endTimeController = TextEditingController();
  var placeController = TextEditingController();
  var valueController = TextEditingController();

  var home = Get.put(HomeViewModel());

  String title = '';
  String place = '';
  String comment = '';

  DateTime? roadDate;

  DateTime? pickedStartDate;

  DateTime? pickedEndDate;

  late Future<TimeOfDay?> selectedStartTime ;
  late Future<TimeOfDay?> selectedEndTime ;

  List<String> valueList = ['상', '중' ,'하'];
  var selectValue = '상';

  int index = 0;
  Mqtt mqtt = new Mqtt();
  //중요도
  @override
  void onInit() async{
    print(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    if(index == null){
      index = 0;
    }
    //오늘
    readToday();
    update();
    super.onInit();
  }

  @override
  void onClose() {
    startController.clear();
    startController.dispose();

    super.onClose();
  }

  readToday(){
    api.requestDateRead('/FamilySchedule/getListAtMonth',DateFormat('yyyy-MM-dd').format(DateTime.now())).then((value) async {
      // if (value['result'] == false) {
      //   SnackBarWidget(serverMsg: '리스트를 불러올 수 없습니다',);
      // } else {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('family_schedule_id', value[index]['family_schedule_id']);
      detailData = value;
      // json.decode(value).cast<Map<String, dynamic>>().toList();
      print(detailData);
      update();
      // }
    });
  }

  Rx<DateTime> selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).obs;
  Rx<CalendarFormat> calendarFormat = CalendarFormat.month.obs;

  Rx<DateTime> focusedDay = DateTime.now().obs;
  // DateTime focusedDay2 = DateTime.now();

  selected(selectedDay2, focusedDay2){
    this.selectedDay.value = selectedDay2;
    this.focusedDay.value = focusedDay2;
    print('날바뀜');
    print(selectedDay2);
    api.requestDateRead('/FamilySchedule/getListAtMonth',DateFormat('yyyy-MM-dd').format(selectedDay2)).then((value) async {
      // if (value['result'] == false) {
      //   SnackBarWidget(serverMsg: '리스트를 불러올 수 없습니다',);
      // } else {
      if(value.length > 0 && value[index]['family_schedule_id'] != null){
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('family_schedule_id', value[index]['family_schedule_id']);
      }
      detailData = value;
          // json.decode(value).cast<Map<String, dynamic>>().toList();

      print(detailData);
      update();
      // }
    });
    update();
  }

  focus(focusedDay) {
    this.focusedDay = focusedDay;
    api.requestDateRead('/FamilySchedule/getListAtMonth',DateFormat('yyyy-MM-dd').format(focusedDay)).then((value) async {
    // if (value['result'] == false) {
    //   SnackBarWidget(serverMsg: '리스트를 불러올 수 없습니다',);
    // } else {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('family_schedule_id', value[index]['family_schedule_id']);
    detailData = value;
        // json.decode(value).cast<Map<String, dynamic>>().toList();
    print(detailData);
    // }
    });
    update();
  }

  formatDate(){

  }

  dropdown(value){
    selectValue = value;
    update();
  }


  //마커 로드
  // List<Event> roadEvent(DateTime day){
  //
  //   //
  //   // // Map<DateTime, List<dynamic>> events = {
  //   // //     DateTime.utc(
  //   // //       int.parse(k[0].toString()) ,int.parse(k[1].toString()),int.parse(k[2].toString())
  //   // // ):e
  //   // // };
  //   // Map<DateTime, List> events = {
  //   //   DateTime.utc(2022,11,13) : [  ],
  //   //   DateTime.utc(2022,11,14) : [ ],
  //   // };
  //   // print(events);
  //   // update();
  //
  //   Map<List<Event>,DateTime> list = {[Event('day')]: DateTime.now()};
  //   for(int i in detailData) {
  //     var start = detailData[i]['startDate'];
  //     var end = detailData[i]['endDate'];
  //     int length = DateTime
  //         .parse(start)
  //         .difference(DateTime.parse(end))
  //         .inDays;
  //     print(i);
  //     list[[Event('day')]] = DateTime.parse(start);
  //     start.add(Duration(days: 1));
  //   }
  //   return list[day] ?? [];
  // }

  // 날짜 선택
  selectDate(type) {
    if(pickedStartDate != null && type == 0){
      print(pickedStartDate);
      String formattedDate = DateFormat('yyyy년 MM월 dd일').format(pickedStartDate!);
      print(formattedDate);
      startController.text = formattedDate; //set output date to TextField value.
        update();
    }else if(pickedEndDate != null && type == 1 ){
      print(pickedEndDate);
      String formattedDate = DateFormat('yyyy년 MM월 dd일').format(pickedEndDate!);
      print(formattedDate);
      endController.text = formattedDate; //set output date to TextField value.
      update();
    }else{
      SnackBarWidget(serverMsg: '날자가 선택되지 않았습니다.',);
      print("Date is not selected");
    }
  }

  selectTime(type,timeOfDay) {
    if(type == 0){
      startTimeController.text = '${timeOfDay.hour.toString()}시 ${timeOfDay.minute.toString()}분';
      pickedStartDate=DateTime.utc(pickedStartDate!.year, pickedStartDate!.month, pickedStartDate!.day,
          timeOfDay.hour,timeOfDay.minute,0,0
      );
      print(pickedStartDate);
    }else{
      endTimeController.text = '${timeOfDay.hour.toString()}시 ${timeOfDay.minute.toString()}분';
      pickedEndDate=DateTime.utc(pickedEndDate!.year, pickedEndDate!.month, pickedEndDate!.day,
          timeOfDay.hour,timeOfDay.minute,0,0
      );
      print('${pickedEndDate}: 포맷팅');
      print(DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedEndDate!));
    }
    update();
  }

  sendSchedule(argument){
      if(titleController.text != null&&pickedStartDate.isBlank != null && pickedEndDate != null && selectValue != null
      &&placeController.text != null && comment != null
      ){

        api.requestSchedule('/FamilySchedule/joinProcess',
            titleController.text.trim(),
            DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedStartDate!),
            DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedEndDate!),
            selectValue,
            placeController.text.trim(),
            comment,argument).then((value) {
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
            refreshDoorUi();
            api.requestDateRead('/FamilySchedule/getListAtMonth',DateFormat('yyyy-MM-dd').format(DateTime.now())).then((value) {
              // if (value['result'] == false) {
              //   SnackBarWidget(serverMsg: '리스트를 불러올 수 없습니다',);
              // } else {
              detailData = value;
              // = json.decode(value).cast<Map<String, dynamic>>().toList();
              print(detailData);
              update();
              // }
            });
            Get.offAll(calendar_view());
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
      } else { Get.snackbar(
        '알림',
        '미완료된 설정이 있습니다. 전부 설정해주세요.'
        ,
        duration: Duration(seconds: 5),
        backgroundColor: const Color.fromARGB(
            255, 39, 161, 220),
        icon: Icon(Icons.info_outline, color: Colors.white),
        forwardAnimationCurve: Curves.easeOutBack,
        colorText: Colors.white,
      );
  }


  }
  deleteSchedule() {
    String familyScheduleId=detailData[index]['family_schedule_id'];
    print(familyScheduleId);
    api.requestDelete('/FamilySchedule/deleteProcess',familyScheduleId).then((value) {
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
        Get.offAll(calendar_view());
        refreshDoorUi();
        api.requestDateRead('/FamilySchedule/getListAtMonth',DateFormat('yyyy-MM-dd').format(DateTime.now())).then((value) {
          // if (value['result'] == false) {
          //   SnackBarWidget(serverMsg: '리스트를 불러올 수 없습니다',);
          // } else {

          detailData = value;
              // json.decode(value).cast<Map<String, dynamic>>().toList();
          print(detailData);
          update();
          // }
        });
        print('${detailData} 삭제완료');

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
 allUpdate(){
    update();
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
class Event {
  String title;

  Event(this.title);
}