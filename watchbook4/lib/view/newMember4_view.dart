import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/newMember_controller.dart';
import 'package:watchbook4/view/newMember5_view.dart';
import 'package:watchbook4/view_model/newMem_view_model.dart';
import 'package:watchbook4/view/widgets/AlertWidget.dart';

class newMember4_view extends GetView<NewMemberController> {
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
                      width: MediaQueryData
                          .fromWindow(WidgetsBinding.instance!.window)
                          .size
                          .width,
                      //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                      height: MediaQueryData
                          .fromWindow(WidgetsBinding.instance!.window)
                          .size
                          .height,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                                width: MediaQueryData
                                    .fromWindow(WidgetsBinding.instance!.window)
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
                                                color: Color.fromARGB(255, 0, 104, 166), shape: BoxShape.circle),
                                            width: 48,
                                            height: 48,
                                          ),
                                        ),
                                        const Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '닉네임 및 아이디 설정',
                                            style:
                                            TextStyle(
                                                fontSize: 23, height: 1.6, color: Color.fromARGB(255, 0, 104, 166)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color.fromARGB(255, 0, 104, 166), width: 1),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              Container(
                                height: MediaQueryData
                                    .fromWindow(WidgetsBinding.instance!.window)
                                    .size
                                    .height - 350,
                                child: SingleChildScrollView(
                                    child: Column(children: [
                                      Container(
                                        height: 220,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: MediaQueryData
                                                  .fromWindow(WidgetsBinding.instance!.window)
                                                  .size
                                                  .width,
                                              margin: const EdgeInsets.only(right: 20),
                                              padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                                              child: const Text(
                                                '아이디를 입력해주세요.',
                                                style: TextStyle(fontSize: 20, color: Colors.white),
                                              ),
                                              decoration: const BoxDecoration(
                                                  color: const Color.fromARGB(255, 0, 104, 166),
                                                  borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(40),
                                                    bottomRight: Radius.circular(40),
                                                  )),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(
                                                      flex: 74,
                                                      child: Container(
                                                        padding: const EdgeInsets.only(left: 20),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: const Color.fromARGB(255, 206, 206, 206))),
                                                        child: TextField(
                                                            controller: NewMemberViewModel.idController,
                                                            //set id controller
                                                            style: const TextStyle(
                                                                color: const Color.fromARGB(255, 206, 206, 206),
                                                                fontSize: 16),
                                                            decoration: const InputDecoration(
                                                              border: InputBorder.none,
                                                              hintText: '아이디를 입력해 주세요.',
                                                              hintStyle:
                                                              TextStyle(
                                                                  color: const Color.fromARGB(255, 206, 206, 206)),
                                                            ),
                                                            onChanged: (value) {
                                                              //변화된 id값 감지
                                                              NewMemberViewModel.id = value;
                                                            }),
                                                      )),
                                                  Expanded(
                                                      flex: 26,
                                                      child: RaisedButton(
                                                        onPressed: () {
                                                          NewMemberViewModel.requestSearchId();
                                                        },
                                                        padding: const EdgeInsets.fromLTRB(0, 17, 0, 17),
                                                        child: const Text('중복확인',
                                                            style: TextStyle(
                                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                                fontSize: 16)),
                                                        color: const Color.fromARGB(255, 108, 158, 207),
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.zero),
                                                      ))
                                                ],
                                              ),
                                            ),
                                            NewMemberViewModel.isUse == 0
                                                ? const Text('* 사용할 아이디를 입력하시고 검색버튼을 눌러주세요.')
                                                : NewMemberViewModel.isUse == 1
                                                ? Text(
                                              '* ${NewMemberViewModel.idController.text.trim()}은(는) 사용가능한 아이디입니다.',
                                              style: const TextStyle(color: Color.fromARGB(255, 108, 158, 207)),
                                            )
                                                : NewMemberViewModel.isUse == 2
                                                ? Text(
                                                '* ${NewMemberViewModel.idController.text.trim()}은(는) 이미 등록된 아이디입니다.',
                                                style: const TextStyle(color: Colors.red))
                                                : NewMemberViewModel.isUse == 3
                                                ? const Text('* ID를 입력해 주세요.', style: TextStyle(color: Colors.red))
                                                : NewMemberViewModel.isUse == 4
                                                ? const Text('* 아이디를 영문, 숫자, 특수문자를 사용해 만들어 주세요.',
                                                style: TextStyle(color: Colors.red))
                                                : NewMemberViewModel.isUse == 5
                                                ? const Text('* 아이디를 최소 6자 이상으로 설정해 주세요.',
                                                style: TextStyle(color: Colors.red))
                                                : const Text('* 관리자에게 문의해주세요.'),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 220,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: MediaQueryData
                                                  .fromWindow(WidgetsBinding.instance!.window)
                                                  .size
                                                  .width,
                                              margin: const EdgeInsets.only(right: 20),
                                              padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                                              child: const Text(
                                                '닉네임을 입력해주세요.',
                                                style: TextStyle(fontSize: 20, color: Colors.white),
                                              ),
                                              decoration: const BoxDecoration(
                                                  color: const Color.fromARGB(255, 0, 104, 166),
                                                  borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(40),
                                                    bottomRight: Radius.circular(40),
                                                  )),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(
                                                      flex: 74,
                                                      child: Container(
                                                        padding: const EdgeInsets.only(left: 20),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: const Color.fromARGB(255, 206, 206, 206))),
                                                        child: TextField(
                                                            controller: NewMemberViewModel.nicknameController,
                                                            //set id controller
                                                            style: const TextStyle(
                                                                color: const Color.fromARGB(255, 206, 206, 206),
                                                                fontSize: 16),
                                                            decoration: const InputDecoration(
                                                              border: InputBorder.none,
                                                              hintText: '닉네임을 입력해주세요.',
                                                              hintStyle:
                                                              TextStyle(
                                                                  color: const Color.fromARGB(255, 206, 206, 206)),
                                                            ),
                                                            onChanged: (value) {
                                                              //변화된 id값 감지
                                                              NewMemberViewModel.nickname = value;
                                                            }),
                                                      )),
                                                  Expanded(
                                                      flex: 26,
                                                      child: RaisedButton(
                                                        onPressed: () {
                                                          NewMemberViewModel.requestSearchNickname();
                                                        },
                                                        padding: const EdgeInsets.fromLTRB(0, 17, 0, 17),
                                                        child: const Text('중복확인',
                                                            style: TextStyle(
                                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                                fontSize: 16)),
                                                        color: const Color.fromARGB(255, 108, 158, 207),
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.zero),
                                                      ))
                                                ],
                                              ),
                                            ),
                                            NewMemberViewModel.isUse2 == 0
                                                ? const Text('* 사용할 닉네임을 입력하시고 중복확인 버튼을 눌러주세요.')
                                                : NewMemberViewModel.isUse2 == 1
                                                ? Text(
                                              '* ${NewMemberViewModel.nicknameController.text.trim()}은(는) 사용가능한 닉네임입니다.',
                                              style: const TextStyle(color: Color.fromARGB(255, 108, 158, 207)),
                                            )
                                                : NewMemberViewModel.isUse2 == 2
                                                ? Text('* ${NewMemberViewModel.nicknameController.text
                                                .trim()}은(는) 이미 등록된 닉네임입니다.',
                                                style: const TextStyle(color: Colors.red))
                                                : NewMemberViewModel.isUse2 == 3
                                                ? const Text('* 등록할 닉네임을 입력해 주세요.')
                                                : const Text('* 관리자에게 문의해주세요.')
                                          ],
                                        ),
                                      ),
                                    ])),
                              )
                            ],
                          ),
                          Container(
                            height: 106,
                            margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 48,
                                  width: double.infinity,
                                  child: RaisedButton(
                                    onPressed: () {
                                      if (NewMemberViewModel.isUse == 1 && NewMemberViewModel.isUse2 == 1) {
                                        NewMemberViewModel.joinId = NewMemberViewModel.idController.text.trim();
                                        NewMemberViewModel.joinNickname =
                                            NewMemberViewModel.nicknameController.text.trim();
                                         NewMemberViewModel.requestValueUpdate();
                                        Get.to(() => newMember5_view());
                                      } else if (NewMemberViewModel.isUse != 1 && NewMemberViewModel.isUse2 == 1) {
                                        NewMemberViewModel.msg = '등록할 아이디를 먼저 인증해 주세요.';
                                        NewMemberViewModel.initDialog(NewMemberViewModel.msg);
                                      }else if (NewMemberViewModel.isUse == 1 && NewMemberViewModel.isUse2 != 1) {
                                        NewMemberViewModel.msg = '등록할 닉네임을 먼저 인증해 주세요.';
                                        NewMemberViewModel.initDialog(NewMemberViewModel.msg);
                                      }
                                    },
                                    child: const Text(
                                      "다음으로",
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                    color: const Color.fromARGB(255, 0, 104, 166),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(color: Color.fromARGB(255, 0, 104, 166)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 48,
                                  width: double.infinity,
                                  child: RaisedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "이전으로",
                                      style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 104, 166)),
                                    ),
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(color: Color.fromARGB(255, 0, 104, 166)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      )),
                )
            )
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}
