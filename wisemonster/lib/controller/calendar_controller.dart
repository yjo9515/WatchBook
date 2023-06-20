
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisemonster/view/calendar_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../api/api_services.dart';
import '../models/mqtt.dart';
import '../view/widgets/SnackBarWidget.dart';
import 'package:intl/intl.dart';

class CalendarController extends GetxController{
  ApiServices api = ApiServices();

  bool isclear = false;

  String readurl = '/FamilySchedule/getList'; //리스트 값 얻을 서버 url 입력
  var detailData;
  var noticeData;
  var nameController = TextEditingController();
  var ddayController = TextEditingController();

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
  // Mqtt mqtt = new Mqtt();

  Map<DateTime, List<Event>> events = {

  };

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
    ddayController.clear();
    ddayController.dispose();

    super.onClose();
  }

  readToday(){
    api.get('/SmartdoorSchedule/lists?startDate=${DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, 1))
    }&stopDate=${DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month+1, 0)
    )}').then((value) {
      if(value.statusCode == 200) {
        detailData = json.decode(value.body);

        for(int i = 0; i < json.decode(value.body)['lists'].length; i++){
          events.addAll({DateTime.utc(DateTime.parse(json.decode(value.body)['lists'][i]['dday']).year,DateTime.parse(json.decode(value.body)['lists'][i]['dday']).month,DateTime.parse(json.decode(value.body)['lists'][i]['dday']).day)  : [
            Event('${json.decode(value.body)['lists'][i]['name']}')
          ]});
        };
        print('달력업데이트');
        update();
        api.get('/SmartdoorNotice/lists').then((value) {
          if(value.statusCode == 200) {
            isclear = true;
            noticeData = json.decode(value.body);
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
    // print('날바뀜');
    // print(selectedDay2);
    // api.get('/SmartdoorSchedule/lists').then((value) {
    //   detailData = value;
    //   update();
    // });
    //
    // api.get('/SmartdoorSchedule/lists?startDate=${DateFormat('yyyy-MM-dd').format(DateTime.now())}').then((value) {
    //   detailData = value;
    //   isclear = true;
    //   update();
    // });
    // api.requestDateRead('/FamilySchedule/getListAtMonth',DateFormat('yyyy-MM-dd').format(selectedDay2)).then((value) async {
    //   // if (value['result'] == false) {
    //   //   SnackBarWidget(serverMsg: '리스트를 불러올 수 없습니다',);
    //   // } else {
    //   if(value.length > 0 && value[index]['family_schedule_id'] != null){
    //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //   sharedPreferences.setString('family_schedule_id', value[index]['family_schedule_id']);
    //   }
    //   detailData = value;
    //       // json.decode(value).cast<Map<String, dynamic>>().toList();
    //
    //   print(detailData);
    //   update();
    //   // }
    // });
    // update();
  }

  focus(focusedDay) {
  }

  formatDate(){

  }

  dropdown(value){
    selectValue = value;
    update();
  }
  List<Event> roadEvent(DateTime day){
    print(events[day]);
    return events[day] ?? [];
  }
  // 날짜 선택
  selectDate(type) {
    if(pickedStartDate != null && type == 0){
      print(pickedStartDate);
      String formattedDate = DateFormat('yyyy년 MM월 dd일').format(pickedStartDate!);
      print(formattedDate);
      ddayController.text = formattedDate; //set output date to TextField value.
      update();
    }else{
      SnackBarWidget(serverMsg: '날자가 선택되지 않았습니다.',);
      print("Date is not selected");
    }
  }

  sendSchedule(argument) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    
      if(nameController.text != null&&ddayController.isBlank != null
      ){
        if(pickedStartDate == null){
         print(detailData['lists'][argument]['dday']);
         pickedStartDate = DateTime.parse(detailData['lists'][argument]['dday']);
         print(pickedStartDate);
        }
        api.post(json.encode({'smartdoor_id': sharedPreferences.getString('smartdoor_id'),'name':nameController.text.trim(),'dday':DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedStartDate!)}), '/SmartdoorSchedule').then((value) {
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
            // refreshDoorUi();
            readToday();
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

  editSchedule(argument) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if(nameController.text != null&&ddayController.isBlank != null
    ){
      if(pickedStartDate == null){
        print(ddayController.text);
        pickedStartDate = DateTime.parse(detailData['lists'][argument]['dday']);
        print(pickedStartDate);
      }
      api.put(json.encode({'smartdoor_id': sharedPreferences.getString('smartdoor_id'),'name':nameController.text.trim(),'dday':DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedStartDate!)}), '/SmartdoorSchedule').then((value) {
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
          // refreshDoorUi();
          readToday();
          // Get.offAll(calendar_view());
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
        // refreshDoorUi();
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
//  refreshDoorUi(){
//    if(mqtt.client?.connectionStatus?.state == MqttConnectionState.disconnected){
//      // home.connect();
//      print('커넥시도');
//    }
//    String? sncode =  home.sharedPreferences.getString('sncode');
//    String topic = 'smartdoor/SMARTDOOR/${sncode}';
//    var builder = MqttClientPayloadBuilder();
//    builder.addString('{"request":"refresh"}');
//    mqtt.client?.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
//  }
}
class Event {
  String title;

  Event(this.title);
}