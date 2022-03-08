import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchbook4/view/findId_view.dart';
import 'package:watchbook4/view/findPw_view.dart';
import 'package:watchbook4/view/home_view.dart';
import 'package:watchbook4/view/login_view.dart';
import 'package:watchbook4/view/newMember_view.dart';
import 'package:watchbook4/view/push_view.dart';
import 'package:watchbook4/view/result_view.dart';
import 'package:watchbook4/view/splash_view.dart';

class HomeController extends GetxController{
  var pages = [
    splash_view(),
    login_view(),
    findId_view(),
    findPw_view(),
    newMember_view(),
    home_view(),
    push_view(),
    result_view(),
  ];



}