
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberController extends GetxController{
  var namecontroller = TextEditingController();
  var phonecontroller = TextEditingController();
  String phone = '';
  String name = '';

  updateContact(value){
    phonecontroller.text = value;
    phone = value;
    Get.back();
    update();
  }

  @override
  void onInit() {
    super.onInit();
  }
}