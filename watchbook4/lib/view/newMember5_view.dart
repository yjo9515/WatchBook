

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/newMember_controller.dart';
import 'package:watchbook4/view_model/newMem_view_model.dart';

class newMember5_view extends GetView<NewMemberController> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetBuilder<NewMemberViewModel>(
        init: NewMemberViewModel(),
    builder: (NewMemberViewModel) =>
        WillPopScope(
            onWillPop: () => _goBack(context),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Container(
                  padding: const EdgeInsets.only(top: 90),
                  width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                      .size
                      .width,
                  //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                  height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                      .size
                      .height,
                  color: Colors.white,
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                          width: MediaQueryData.fromWindow(
                              WidgetsBinding.instance!.window)
                              .size
                              .width,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: const Text('03',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          )),
                                      decoration: const BoxDecoration(
                                          color: Color.fromARGB(255, 0, 104, 166),
                                          shape: BoxShape.circle),
                                      width: 48,
                                      height: 48,
                                    ),
                                  ),
                                  const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '비밀번호 설정',
                                      style: TextStyle(
                                          fontSize: 23,
                                          height: 1.6,
                                          color: Color.fromARGB(255, 0, 104, 166)),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: const Color.fromARGB(255, 0, 104, 166),
                                width: 1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        Container(
                            height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                                .size
                                .height - 350,
                            child: SingleChildScrollView(
                                child:Column(
                                    children: [
                                      Container(
                                        height: 220,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: MediaQueryData.fromWindow(
                                                  WidgetsBinding.instance!.window)
                                                  .size
                                                  .width,
                                              margin: const EdgeInsets.only(right: 20),
                                              padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                                              child: const Text(
                                                '비밀번호를 입력해주세요.',
                                                style: TextStyle(fontSize: 20, color: Colors.white),
                                              ),
                                              decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 0, 104, 166),
                                                  borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(40),
                                                    bottomRight: Radius.circular(40),
                                                  )),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                                              child: Container(
                                                padding: const EdgeInsets.only(left: 20),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: const Color.fromARGB(
                                                            255, 206, 206, 206)
                                                    )
                                                ),
                                                child: Obx(() => TextField(
                                                  controller: NewMemberViewModel.passwdController,
                                                  //set passwd controller
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 206, 206, 206), fontSize: 16),
                                                  obscureText: !NewMemberViewModel.isObscure.value,
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText: '4자리 이상 입력해주세요.',
                                                      hintStyle: const TextStyle(color: Color.fromARGB(
                                                          255, 206, 206, 206)),
                                                      suffixIcon: IconButton(
                                                        icon: Icon(
                                                            NewMemberViewModel.isObscure.value
                                                                ? Icons.visibility
                                                                : Icons.visibility_off,
                                                            color: Colors.black),
                                                        onPressed: () {
                                                          NewMemberViewModel.isObscure.value = !NewMemberViewModel.isObscure.value;
                                                        },
                                                      )),
                                                  onChanged: (value) {
                                                    // change passwd text
                                                    NewMemberViewModel.passwd = value;
                                                  },
                                                )),
                                              ),
                                            ),
                                            Container(
                                                margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                                child:
                                                NewMemberViewModel.msg.isEmpty ?
                                                Text(''):
                                                Text('* ${NewMemberViewModel.msg}',
                                                    style:const TextStyle(
                                                        color: Colors.red))
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 220,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: MediaQueryData.fromWindow(
                                                  WidgetsBinding.instance!.window)
                                                  .size
                                                  .width,
                                              margin: const EdgeInsets.only(right: 20),
                                              padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                                              child: const Text(
                                                '비밀번호를 한 번 더 입력해주세요.',
                                                style: TextStyle(fontSize: 20, color: Colors.white),
                                              ),
                                              decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 0, 104, 166),
                                                  borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(40),
                                                    bottomRight: Radius.circular(40),
                                                  )),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                                              child: Container(
                                                padding: const EdgeInsets.only(left: 20),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: const Color.fromARGB(
                                                            255, 206, 206, 206)
                                                    )
                                                ),
                                                child: Obx(
                                                    () => TextField(
                                                      controller: NewMemberViewModel.pwcheckController,
                                                      //set passwd controller
                                                      style: const TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 206, 206, 206), fontSize: 16),
                                                      obscureText: !NewMemberViewModel.isObscure2.value,
                                                      decoration: InputDecoration(
                                                          border: InputBorder.none,
                                                          hintText: '비밀번호를 한 번 더 입력해주세요.',
                                                          hintStyle: const TextStyle(color: Color.fromARGB(
                                                              255, 206, 206, 206)),
                                                          suffixIcon: IconButton(
                                                            icon: Icon(
                                                                NewMemberViewModel.isObscure2.value
                                                                    ? Icons.visibility
                                                                    : Icons.visibility_off,
                                                                color: Colors.black),
                                                            onPressed: () {
                                                              NewMemberViewModel.isObscure2.value = !NewMemberViewModel.isObscure2.value;
                                                            },
                                                          )),
                                                      onChanged: (value) {
                                                        // change passwd text
                                                        NewMemberViewModel.pwcheck = value;
                                                      },
                                                    )
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ]
                                )
                            )
                        )
                      ],),
                      Container(
                        height: 106,
                        margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 48,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  NewMemberViewModel.requestJoinProcess();
                                },
                                child: const Text(
                                  "가입하기",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255, 0, 104, 166),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: Color.fromARGB(
                                            255, 0, 104, 166)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                )
                              ),
                            ),
                            SizedBox(
                              height: 48,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "이전으로",
                                  style: TextStyle(
                                      fontSize: 16, color: Color.fromARGB(
                                      255, 0, 104, 166)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255, 255, 255, 255),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: Color.fromARGB(
                                            255, 0, 104, 166)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                )
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
              ),
            ))
    );
  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
 }