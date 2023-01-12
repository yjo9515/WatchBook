import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/controller/profile_controller.dart';
import 'package:wisemonster/view/calendar_view.dart';
import 'package:wisemonster/view/config_view.dart';
import 'package:wisemonster/view/entrance_view.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/key_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/nickname_view.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:wisemonster/view_model/login_view_model.dart';
import 'dart:io' as i;

import '../../models/user_model.dart';
import '../notice_view.dart';
import '../video_view.dart';

class LeftSlideWidget extends StatelessWidget {
  String userName = '';
  String pictureUrl = '';
  final home = Get.put(HomeViewModel());
  final login = Get.put(LoginViewModel());


  getName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userName = sharedPreferences.getString('nickname')!;
    print('회원이름 호출');
    print(userName);
    return await userName;
  }

  getImage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    pictureUrl = sharedPreferences.getString('pictureUrl')!;
    print('프로필사진 주소');
    print(pictureUrl);
    return pictureUrl;
  }

  // LeftSlideWidget({
  //   required this.serverMsg,
  //   required this.error,
  // });
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 288,
        child: Drawer(
          child: ListView(
            //메모리 문제해결
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            padding: EdgeInsets.zero, // 여백x
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
              Container(
              width: MediaQueryData
                  .fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              height: MediaQueryData
                  .fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .height - 60,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          color: Color.fromARGB(255, 18, 136, 248),
                          icon: Icon(
                            Icons.arrow_back_ios_new_outlined,
                            size: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.offAll(home_view()),
                          color: Color.fromARGB(255, 18, 136, 248),
                          icon: Icon(
                            Icons.home_outlined,
                            size: 25,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                      height: 152,
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: Column(
                        children: [
                          TextButton(onPressed: () {}, child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 161, 161, 161),
                            ),
                            child:
                            FutureBuilder(
                                future: getImage(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return CircleAvatar(
                                        backgroundImage: Image
                                            .network('https://www.smartdoor.watchbook.tv${pictureUrl}')
                                            .image
                                    );
                                  } else {
                                    return Icon(
                                      Icons.image,
                                      color: Colors.white,
                                      size: 30,
                                    );
                                  }
                                }))),
                            Container(
                              height: 12,
                            ),
                            FutureBuilder(
                                future: getName(),
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    return
                                      Text('${snapshot.data} 님',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color.fromARGB(255, 43, 43, 43),
                                        ),);
                                  } else {
                                    return Text('닉네임을 등록해주세요.',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Color.fromARGB(255, 43, 43, 43),
                                      ),
                                    );
                                  }
                                })
                            ,
                            ],
                          ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(notice_view());
                              print('공지');
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                                backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                            child: Text(
                              '공지사항',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 18, 136, 248),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(calendar_view());
                              print('캘린더');
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                                backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                            child: Text(
                              '캘린더',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 18, 136, 248),
                              ),
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {
                          //     Get.to(key_view());
                          //   },
                          //   style: TextButton.styleFrom(
                          //       padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                          //       backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                          //   child: Text(
                          //     '게스트 키',
                          //     style: TextStyle(
                          //       fontSize: 14,
                          //       color: Color.fromARGB(255, 18, 136, 248),
                          //     ),
                          //   ),
                          // ),
                          TextButton(
                            onPressed: () {
                              Get.to(entrance_view());
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                                backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                            child: Text(
                              '출입기록',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 18, 136, 248),
                              ),
                            ),
                          ),
                  TextButton(
                    onPressed: () {
                      Get.to(video_view());
                    },
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                        backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                    child: Text(
                      '녹화기록',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 18, 136, 248),
                      ),
                    ),
                  ),
                          // TextButton(
                          //   onPressed: () {},
                          //   style: TextButton.styleFrom(
                          //       padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                          //       backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                          //   child: Text(
                          //     '구성원',
                          //     style: TextStyle(
                          //       fontSize: 14,
                          //       color: Color.fromARGB(255, 18, 136, 248),
                          //     ),
                          //   ),
                          // ),
                          TextButton(
                            onPressed: () {
                              Get.to(()=>profile_view());
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                                backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                            child: Text(
                              '내 프로필',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 18, 136, 248),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(config_view());
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                                backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                            child: Text(
                              '설정',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 18, 136, 248),
                              ),
                            ),
                          ),
                        ],
                      )),
                  TextButton(
                    onPressed: () {
                      login.logoutProcess();
                    },
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                        backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                    child: Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 161, 161, 161),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}