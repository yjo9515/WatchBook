import 'dart:async';
import 'dart:convert';
import 'dart:io' as i;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/controller/home_controller.dart';

import 'package:wisemonster/view/widgets/LeftSlideWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';

import 'camera_view.dart';

class home_view extends GetView<HomeController> {
  home_view({Key? key}) : super(key: key);
  String userName = '';
  getName() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userName = sharedPreferences.getString('name')!;
    print('회원이름 호출');
    print(userName);
    return await userName;
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return GetBuilder<HomeViewModel>(
      init: HomeViewModel(),
      builder: (HomeViewModel) => WillPopScope(
          onWillPop: () => _goBack(context),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
                child: Container(
                    width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                    height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 20,
                    child: Stack(
                      children: [
                        Positioned(
                            top: 0,
                            child: Container(
                              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                              height: 388,
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 87, 132, 255),
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(40), bottomLeft: Radius.circular(40))),
                              padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('우리집',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color.fromARGB(255, 255, 255, 255),
                                      )),
                                  Container(
                                    height: 20,
                                  ),
                                  TextButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(120.0),
                                        )),
                                      ),
                                      onPressed: () {},
                                      child: Container(
                                        width: 220,
                                        height: 220,
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(255, 44, 95, 233),
                                            borderRadius: BorderRadius.all(Radius.circular(120))),
                                        child: Container(
                                          child: Container(
                                            child: Icon(Icons.lock_open,
                                                size: 40, color: Color.fromARGB(255, 255, 255, 255)),
                                            margin: EdgeInsets.fromLTRB(25, 25, 25, 25),
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                                color: Color.fromARGB(255, 14, 39, 158),
                                                borderRadius: BorderRadius.all(Radius.circular(100))),
                                          ),
                                          margin: EdgeInsets.fromLTRB(25, 25, 25, 25),
                                          width: 170,
                                          height: 170,
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(255, 87, 132, 255),
                                              borderRadius: BorderRadius.all(Radius.circular(100))),
                                        ),
                                      )),
                                  Container(
                                    height: 20,
                                  ),
                                  Text('도어락이 열려있습니다.',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Color.fromARGB(255, 255, 255, 255),
                                      )),
                                ],
                              ),
                            )),
                        Positioned(
                            top: 364,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.resolveWith(
                                        (states) {
                                          if (states.contains(MaterialState.disabled)) {
                                            return Colors.grey;
                                          } else {
                                            return Colors.white;
                                          }
                                        },
                                      ),
                                      shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(30)))),
                                    ),
                                    onPressed: () {
                                      Get.to(camera_view());
                                    },
                                    child: Text('외부카메라',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color.fromARGB(255, 87, 132, 255),
                                        )),
                                  ),
                                ),
                                Container(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.resolveWith(
                                        (states) {
                                          if (states.contains(MaterialState.disabled)) {
                                            return Colors.grey;
                                          } else {
                                            return Colors.white;
                                          }
                                        },
                                      ),
                                      shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(30)))),
                                    ),
                                    onPressed: () {},
                                    child: Text('출입이력',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color.fromARGB(255, 87, 132, 255),
                                        )),
                                  ),
                                ),
                                Container(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.resolveWith(
                                        (states) {
                                          if (states.contains(MaterialState.disabled)) {
                                            return Colors.grey;
                                          } else {
                                            return Colors.white;
                                          }
                                        },
                                      ),
                                      shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(30)))),
                                    ),
                                    onPressed: () {},
                                    child: Text('구성원',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color.fromARGB(255, 87, 132, 255),
                                        )),
                                  ),
                                )
                              ],
                            ))
                      ],
                    ))),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Color.fromARGB(255, 87, 132, 255),
              iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
              actions: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Row(
                    children: [
                      FutureBuilder(
                          future: getName(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text('${snapshot.data} 님',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),);
                            } else {
                              return Text('회원님',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              );
                            }
                          }),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.account_circle, size: 19, color: Color.fromARGB(255, 255, 255, 255)),
                      )
                    ],
                  ),
                )
              ],
            ),
            drawer: LeftSlideWidget(),
          )),
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
