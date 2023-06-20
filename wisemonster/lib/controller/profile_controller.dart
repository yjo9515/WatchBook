import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController{
  var nicknameController = TextEditingController();
  var tagController = TextEditingController();
  String nickname = '';
  String tag = '';
  ApiServices api = ApiServices();
  List? Tagdata;
  String readurl = ''; //리스트 값 얻을 서버 url 입력
  String deleteurl = '';
  String sendurl = '';
  var listData;
  bool isclear = false;

  final ImagePicker _picker = ImagePicker();
  File? image;
  String imageUrl = '';
  @override
  void onInit() async {

    requestTag();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString('nickname') != null ){
      nickname =  sharedPreferences.getString('nickname')!;
    }
    if(sharedPreferences.getString('pictureUrl') != null ){
      imageUrl = sharedPreferences.getString('pictureUrl')!;
    }

    print(imageUrl);
    update();
    super.onInit();
  }


  Future getImage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final XFile? pickImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickImage != null){
      image = File(pickImage.path);
      final bytes = image?.readAsBytesSync();
      String base64Image =  "data:image/png;base64,"+base64Encode(bytes!);
      print(base64Image);
      // api.post(json.encode({'file':base64Image}), '/User/pictureUpload').then((value) {
      //   print(value);
      // });
      api.requestImageProcess('/User/pictureUpload', base64Image).then((value){
        print('결과');
        if (value.statusCode == 200) {
          api.get('/User/${sharedPreferences.getString('user_id')}').then((value) {
            print(value);
            print(value.body);
            print(utf8.decode(value.reasonPhrase!.codeUnits));
            if (value.statusCode == 200) {
              Get.snackbar(
                '알림',
                '사진 등록이 완료되었습니다.'
                ,
                duration: Duration(seconds: 5),
                backgroundColor: const Color.fromARGB(
                    255, 39, 161, 220),
                icon: Icon(Icons.info_outline, color: Colors.white),
                forwardAnimationCurve: Curves.easeOutBack,
                colorText: Colors.white,
              );
              print(json.decode(value.body)['picture']['url']);
              sharedPreferences.setString('pictureUrl', json.decode(value.body)['picture']['url']);
              imageUrl =  '${json.decode(value.body)['picture']['url']}?ver=${DateTime.now().toString()}';
              print(imageUrl);
              // print(value);
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
            }
            else {
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
        }else{
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
  }

  requestTag(){
    print('프로필조회구간');
    api.get('/SmartdoorItem/lists').then((value) {
      if (value.statusCode == 200) {
        listData = json.decode(value.body);
        print(listData);
        isclear = true;
        update();
      } else {
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits),
          duration: const Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: const Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }
    });
  }

  void sendNickname() {
    api.post(json.encode({'nickname': nicknameController.text.trim()}), '/User/nickname').then((value) async {
      if (value.statusCode == 200) {
        Get.back();
        Get.snackbar(
          '알림',
          '닉네임이 변경되었습니다.'
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
        print('${nicknameController.text.trim()} 닉네임변경값');
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('nickname',nicknameController.text.trim());
        nickname = nicknameController.text.trim();
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
      }
      else {
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
    // api.requestNickNameProcess(nicknameController.text.trim()).then((value) async {
    //   if (value['result'] == false) {
    //     SnackBarWidget(serverMsg: value['message'],);
    //   } else {
    //     print(value);
    //     if (value['result'] == true) {
    //       Get.offAll(profile_view());
    //       Get.snackbar(
    //         '알림',
    //         '닉네임이 변경되었습니다.'
    //         ,
    //         duration: Duration(seconds: 5),
    //         backgroundColor: const Color.fromARGB(
    //             255, 39, 161, 220),
    //         icon: Icon(Icons.info_outline, color: Colors.white),
    //         forwardAnimationCurve: Curves.easeOutBack,
    //         colorText: Colors.white,
    //       );
    //       print('${value['params']['nickname']} 닉네임변경값');
    //       SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //       sharedPreferences.setString('nickname',value['params']['nickname']);
    //        nickname = value['params']['nickname'];
    //       update();
    //     } else {
    //       Get.snackbar(
    //         '알림',
    //         value['massage']
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
    //   }
    // });
  }

  //소지품등록
  void sendTag() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString('smartdoor_id'));
    print(sharedPreferences.getString('user_id'));
    api.post(json.encode({'name':tagController.text}), '/SmartdoorItem').then((value) {
      print(value);
      if (value.statusCode == 200) {
              Get.back();
              requestTag();
              Get.snackbar(
                '알림',
                '소지품 등록이 완료되었습니다.'
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
              Get.back();
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

  //소지품삭제
  void deleteTag(index) {
    String smartdoor_item_id = listData['lists'][index]['smartdoor_item_id'];
    print('smartdoor_item_id : ${smartdoor_item_id}');
    api.delete('/SmartdoorItem/${smartdoor_item_id}').then((value) {
      print(value.statusCode);
      if(value.statusCode == 200) {
        Get.back();
        requestTag();
        Get.snackbar(
          '알림',
          '소지품 삭제가 완료되었습니다.'
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
    // api.requestDeleteTag('/FamilyItem/deleteProcess',familyScheduleId).then((value) {
    //   if (value == false) {
    //     SnackBarWidget(serverMsg: value['message'],);
    //   } else {
    //     print(value);
    //     if (value['result'] == true) {
    //       requestTag();
    //       Get.offAll(profile_view());
    //         Get.snackbar(
    //           '알림',
    //           '소지품 삭제가 완료되었습니다.'
    //           ,
    //           duration: Duration(seconds: 5),
    //           backgroundColor: const Color.fromARGB(
    //               255, 39, 161, 220),
    //           icon: Icon(Icons.info_outline, color: Colors.white),
    //           forwardAnimationCurve: Curves.easeOutBack,
    //           colorText: Colors.white,
    //         );
    //       update();
    //     } else {
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
    //   }
    // });
  }
}