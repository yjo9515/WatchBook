import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';

import '../api/api_services.dart';
import '../view/widgets/QuitWidget.dart';

class KeyViewModel extends GetxController{

  ApiServices api = ApiServices();
  var startController = TextEditingController();
  var endController = TextEditingController();
  var startTimeController = TextEditingController();
  var endTimeController = TextEditingController();
  var passwdController = TextEditingController();
  var phonecontroller = TextEditingController();

  late DateTime pickedStartDate;

  late DateTime pickedEndDate;

  late Future<TimeOfDay?> selectedStartTime ;
  late Future<TimeOfDay?> selectedEndTime ;

  String phone = '';
  String pw = '';

  // sendSchedule(){
  //   api.requestSchedule('/FamilySchedule/saveAll',title,
  //       DateFormat('yyyy-MM-ddHH:ii:ss').format(pickedStartDate),
  //       DateFormat('yyyy-MM-ddHH:ii:ss').format(pickedEndDate),
  //       selectValue,
  //       place,
  //       comment).then((value) {
  //     if (value == false) {
  //       SnackBarWidget(serverMsg: value['message'],);
  //     } else {
  //       listData = value;
  //       update();
  //     }
  //   });
  // }

  selectDate(type) {
    if(pickedStartDate != null && type == 0){
      print(pickedStartDate);
      String formattedDate = DateFormat('yyyy년 MM월 dd일').format(pickedStartDate);
      print(formattedDate);
      startController.text = formattedDate; //set output date to TextField value.
      update();
    }else if(pickedEndDate != null && type == 1 ){
      print(pickedEndDate);
      String formattedDate = DateFormat('yyyy년 MM월 dd일').format(pickedEndDate);
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
      pickedStartDate=DateTime.utc(pickedStartDate.year, pickedStartDate.month, pickedStartDate.day,
          timeOfDay.hour,timeOfDay.minute
      );
      print(pickedStartDate);
    }else{
      endTimeController.text = '${timeOfDay.hour.toString()}시 ${timeOfDay.minute.toString()}분';
      pickedEndDate=DateTime.utc(pickedEndDate.year, pickedEndDate.month, pickedEndDate.day,
          timeOfDay.hour,timeOfDay.minute
      );
      print(pickedEndDate);
    }
    update();
  }

  updateContact(value){
    phonecontroller.text = value;
    phone = value;
    Get.back();
    update();
  }

  createKey(){
    api.getKey('/FamilySchedule/saveAll').then((value) async {
      if (value == false) {
        Get.dialog(
            QuitWidget(serverMsg: "키 발행에 실패하였습니다.",)
        );
        update();
      } else {

      }
    });
  }
}