import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/calendar_view.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/key_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../../models/user_model.dart';

class LeftSlideWidget extends StatelessWidget {
  String userName = '';
  final home = Get.put(HomeViewModel());

  getName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userName = sharedPreferences.getString('name')!;
    print('회원이름 호출');
    print(userName);
    return await userName;
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
                                  onPressed: () => Navigator.of(context).pop(),
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
                                TextButton(onPressed: () {
                                  home.getImage();
                                }, child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 161, 161, 161),
                                    ),
                                    child: home.image != null
                                        ? CircleAvatar(
                                      backgroundImage: Image
                                          .file(
                                        i.File(home.image!.path),
                                        fit: BoxFit.cover,
                                      )
                                          .image,
                                    )
                                        : Icon(
                                        Icons.add,
                                            color: Colors.white,
                                      size: 30,
                                    )),),

                                Container(
                                  height: 12,
                                ),
                                FutureBuilder(
                                    future: getName(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text('${snapshot.data} 님',
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Color.fromARGB(255, 43, 43, 43),
                                          ),);
                                      } else {
                                        return Text('회원님',
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
                          TextButton(
                            onPressed: () {
                              Get.to(key_view());
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                                backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                            child: Text(
                              '게스트 키',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 18, 136, 248),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                                backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                            child: Text(
                              '게스트 키',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 18, 136, 248),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                                backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                            child: Text(
                              '게스트 키',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 18, 136, 248),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              home.getImage();
                            },
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                                backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                            child: Text(
                              '게스트 키',
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
                      home.logoutProcess();
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