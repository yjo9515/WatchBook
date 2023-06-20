
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/member_edit_view.dart';

import '../view/member_view.dart';
import '../view/widgets/SnackBarWidget.dart';

class MemberController extends GetxController{
  var namecontroller = TextEditingController();
  var phonecontroller = TextEditingController();
  var mesaagecontroller = TextEditingController();
  String massage = '';
  ApiServices api = ApiServices();
  String phone = '';
  String name = '';
  bool isclear = false;
  var listData;
  var messageData;
  updateContact(value){
    phonecontroller.text = value;
    phone = value;
    Get.back();
    update();
  }

  requestMember() {
    print('맴버조회구간');
    api.get('/SmartdoorUser/lists').then((value) {
      if (value.statusCode == 200) {
        listData = json.decode(value.body) ;
        print('맴버 데이터 : ${listData}');
        isclear = true;

        update();
      }else if (value.statusCode == 401) {
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
      }
      else{
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
    // api.requestRead('/SmartdoorItem/lists').then((value) {
    //   if (value == false) {
    //     SnackBarWidget(serverMsg: value['message'],);
    //   } else {
    //     listData = value;
    //     print(listData[1]['name']);
    //     update();
    //   }
    // });
  }

  void sendMessage(user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString('smartdoor_id'));
    print(sharedPreferences.getString('user_id'));
    api.post(json.encode({'smartdoor_id':sharedPreferences.getString('smartdoor_id'),'to_user_id':user_id,'msg':mesaagecontroller.text}), '/SmartdoorMessage').then((value) {
      print(value);
      if(value.statusCode == 200) {
        Get.back();
        // requestMessage(sharedPreferences.getString('user_id'));
        Get.back();
        Get.snackbar(
          '알림',
          '메세지작성이 완료되었습니다.'
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
        update();
      } else if (value.statusCode == 401) {
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
        update();
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
        update();
      }
    });
    // api.requestTagProcess('/FamilyItem/saveAll',tagController.text).then((value) {
    //     print(value);
    //     if (value['result'] == true) {
    //       requestTag();
    //       Get.off(profile_view());
    //       Get.snackbar(
    //         '알림',
    //         '소지품 등록이 완료되었습니다.'
    //         ,
    //         duration: Duration(seconds: 5),
    //         backgroundColor: const Color.fromARGB(
    //             255, 39, 161, 220),
    //         icon: Icon(Icons.info_outline, color: Colors.white),
    //         forwardAnimationCurve: Curves.easeOutBack,
    //         colorText: Colors.white,
    //       );
    //       update();
    //     } else {
    //       Get.back();
    //       Get.snackbar(
    //         '알림',
    //         value['message']
    //         ,
    //         duration: Duration(seconds: 5),
    //         backgroundColor: const Color.fromARGB(
    //             255, 39, 161, 220),
    //         icon: Icon(Icons.info_outline, color: Colors.white),
    //         forwardAnimationCurve: Curves.easeOutBack,
    //         colorText: Colors.white,
    //       );
    //       update();
    //     }
    //     //user = UserModel.fromJson(value);
    //
    // });
  }

  // void requestMessage() {
  //   print('메세지조회구간');
  //   api.get('/SmartdoorMessage/lists').then((value){
  //     if(value.statusCode == 200) {
  //
  //       print(json.decode(value.body));
  //       print(json.decode(value.body)['to_user_id']);
  //       // if(json.decode(value.body)['to_user_id'] =)
  //       messageData = json.decode(value.body);
  //       print(messageData);
  //       print('조회완료');
  //       update();
  //     }
  //     else if(value.statusCode == 401) {
  //       Get.offAll(login_view());
  //       Get.snackbar(
  //         '알림',
  //         utf8.decode(value.reasonPhrase!.codeUnits)
  //         ,
  //         duration: Duration(seconds: 5),
  //         backgroundColor: const Color.fromARGB(
  //             255, 39, 161, 220),
  //         icon: Icon(Icons.info_outline, color: Colors.white),
  //         forwardAnimationCurve: Curves.easeOutBack,
  //         colorText: Colors.white,
  //       );
  //       update();
  //     }
  //     else {
  //       Get.back();
  //       Get.snackbar(
  //         '알림',
  //         utf8.decode(value.reasonPhrase!.codeUnits)
  //         ,
  //         duration: Duration(seconds: 5),
  //         backgroundColor: const Color.fromARGB(
  //             255, 39, 161, 220),
  //         icon: Icon(Icons.info_outline, color: Colors.white),
  //         forwardAnimationCurve: Curves.easeOutBack,
  //         colorText: Colors.white,
  //       );
  //       update();
  //     }
  //   });
  // }

  requestMessage(idx){
    print('메세지조회구간');
    api.get('/SmartdoorMessage/lists').then((value) {
      if(value.statusCode == 200) {
        print('받은 user_id : ${idx}');
        print(json.decode(value.body)['lists'].length);
        List k = [];
        for(int i = 0; i < json.decode(value.body)['lists'].length; i++){
          print('값 : ${json.decode(value.body)['lists'][i]['to_user_id']}');
          if(json.decode(value.body)['lists'][i]['to_user_id'].toString() == idx.toString()){
            print(json.decode(value.body)['lists'][i]);
            k.add(json.decode(value.body)['lists'][i]);
          }
        }
        print(k);
        messageData = k;
        // isClear = true;
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

  void deleteMember(index) {
    print(index);
    print(listData['lists']);
    String smartdoor_user_invite_id = listData['lists'][index]['smartdoor_user_id'];
    print('smartdoor_item_id : ${smartdoor_user_invite_id}');
    api.delete('/SmartdoorUser/${smartdoor_user_invite_id}').then((value) {
      if(value.statusCode == 200) {
        requestMember();
        Get.snackbar(
          '알림',
          '구성원 삭제가 완료되었습니다.'
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
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

  @override
  void onInit() {
    requestMember();
    // requestMessage();
    super.onInit();
  }


}