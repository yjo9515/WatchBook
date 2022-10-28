import 'dart:async';
import 'dart:convert';
import 'dart:io' as i;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/controller/home_controller.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/H2.dart';

import 'package:wisemonster/view/widgets/LeftSlideWidget.dart';
import 'package:wisemonster/view/widgets/QrWidget.dart';
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
          child:  Scaffold(
            resizeToAvoidBottomInset: false,
            body:
              SafeArea(
                  child:
                  (HomeViewModel.register)?
                  Container(
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
                                        onPressed: () {

                                        },
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
                      )) :
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      PageView(
                        pageSnapping: true,
                        controller: HomeViewModel.pagecontroller,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                                  width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                                  height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                                      .size
                                      .height- 186,
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: MediaQueryData.fromWindow(
                                            WidgetsBinding.instance!.window)
                                            .size
                                            .width,

                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                H1(changeValue: '제품 등록',size: 20,),
                                              ],
                                            ),
                                            Container(height: 20,),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                H2(changeValue: '1. ',),
                                                Expanded(child: H2(changeValue: '와이즈 몬스터 앞에서 전원을 켜고 설치를 진행합니다.',))
                                              ],
                                            ),
                                            Container(height: 15,),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                H2(changeValue: '2. ',),
                                                Expanded(child: H2(changeValue: '미러 안내 화면에서 와이즈 몬스터 wifi 화면이 보이면\n아래 다음을 누르고 진행해주세요.',))
                                              ],
                                            ),
                                            Container(height: 30,),
                                            Container(height: 30,),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('※ ',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(255, 255, 0, 0),
                                                      fontSize: 15
                                                  ),),
                                                Expanded(child: Text('위 화면이 보이지 않는다면 이미 마스터가 존재하는 제품입니다. 구성원에게 확인 후 마스터가 없다면 제품의 초기화 버튼을 통해 초기화 진행 후 다시 시도해주세요.',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(255, 255, 0, 0),
                                                      fontSize: 15
                                                  ),
                                                ))
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                                  width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                                  height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                                      .size
                                      .height- 186,
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: MediaQueryData.fromWindow(
                                            WidgetsBinding.instance!.window)
                                            .size
                                            .width,

                                        child: Column(

                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                H1(changeValue: '제품 등록',size: 20,),
                                                Container(height: 20,),
                                                Text('아래 QR코드 촬영 버튼을 누르고 미러 안내 화면에 표시된\n제품 등록 QR코드를 촬영하여 주십시오.'
                                                  ,style: TextStyle(
                                                      fontSize: 15,
                                                      height: 1.5
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(height: 82,),
                                            TextButton(
                                              style: ButtonStyle(
                                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(120.0),
                                                )),
                                              ),
                                              onPressed: () {
                                                Get.dialog(
                                                  QrWidget()
                                                );
                                              },
                                              child: Container(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.qr_code_scanner,
                                                        size: 32, color: Color.fromARGB(255, 87, 132, 255)),
                                                    Text('QR코드 촬영',style: TextStyle(
                                                        fontSize: 14,
                                                        height: 1.5
                                                    ),)
                                                  ],
                                                ),
                                                margin: EdgeInsets.fromLTRB(25, 25, 25, 25),
                                                width: 160,
                                                height: 160,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Color.fromARGB(255, 87, 132, 255)
                                                    ),
                                                    borderRadius: BorderRadius.all(Radius.circular(100))),
                                              ),)
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ],
                        onPageChanged: (value){
                          HomeViewModel.sController.add(value);
                        },

                      ),
                      Positioned(
                        bottom: 40,
                        child:  Container(
                          width: 50,
                          height: 50,
                          child: StreamBuilder<dynamic>(
                              stream: HomeViewModel.sController.stream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: 2,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: (snapshot.data == index)
                                                  ? Color.fromARGB(255, 87, 132, 255)
                                                  : Colors.grey),
                                        );
                                      });
                                }
                                return Container();
                              }),
                        ),
                      ),
                    ],
                  )

              ),

            appBar: (HomeViewModel.register)?AppBar(
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
            ):AppBar(
                centerTitle: true,
                backgroundColor: Color.fromARGB(255, 42, 66, 91),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
                title:
                Container(
                  width: 132,
                  height: 20,
                  child: Image.asset(
                    'images/default/w_logo.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  ),
                )
            ),
            drawer: (HomeViewModel.register) ?
            LeftSlideWidget() :
            null,
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
