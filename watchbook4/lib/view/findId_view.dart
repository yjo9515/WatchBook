import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/findId_controller.dart';
import 'package:watchbook4/view_model/findId_view_model.dart';

class findId_view extends GetView<FindIdController>{
  findId_view({Key? key}) : super(key: key);
  String phone = '';
  String name = '';
  var _phone = TextEditingController();
  var _name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetBuilder<FindIdViewModel>(
        init: FindIdViewModel(),
        builder: (FindIdViewModel) =>
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                              padding: const EdgeInsets.fromLTRB(0, 13, 0, 13),
                              width: MediaQueryData.fromWindow(
                                  WidgetsBinding.instance!.window)
                                  .size
                                  .width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    '아이디 찾기',
                                    style: TextStyle(
                                        fontSize: 23,
                                        color: Color.fromARGB(255, 0, 104, 166)),
                                  )
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
                              height: 176,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQueryData.fromWindow(
                                        WidgetsBinding.instance!.window)
                                        .size
                                        .width,
                                    margin: const EdgeInsets.only(right: 20),
                                    padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                                    child: const Text(
                                      '이름을 입력해주세요.',
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
                                      padding: const EdgeInsets.only(left: 20),
                                      margin: const EdgeInsets.fromLTRB(20, 30, 20, 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 206, 206, 206)
                                          )
                                      ),
                                      child: TextField(
                                          controller: _name, //set id controller
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 206, 206, 206), fontSize: 16),
                                          decoration: const InputDecoration(
                                              hintText: '이름',
                                              hintStyle: TextStyle(color: Color.fromARGB(
                                                  255, 206, 206, 206)),
                                              border: InputBorder.none
                                          ),
                                          onChanged: (value) {
                                            //변화된 id값 감지
                                            name = value;
                                          })),
                                ],
                              ),
                            ),
                            Container(
                              child: Column(
                                children: [
                                  Container(
                                    width: MediaQueryData.fromWindow(
                                        WidgetsBinding.instance!.window)
                                        .size
                                        .width,
                                    margin: const EdgeInsets.only(right: 20),
                                    padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                                    child: const Text(
                                      '휴대폰 번호를 입력해주세요.',
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
                                      padding: const EdgeInsets.only(left: 20),
                                      margin: const EdgeInsets.fromLTRB(20, 30, 20, 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 206, 206, 206)
                                          )
                                      ),
                                      child: TextField(
                                          controller: _phone, //set id controller
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 206, 206, 206), fontSize: 16),
                                          decoration: const InputDecoration(
                                              hintText: '- 없이 입력해주세요.',
                                              hintStyle: TextStyle(color: Color.fromARGB(
                                                  255, 206, 206, 206)),
                                              border: InputBorder.none
                                          ),
                                          onChanged: (value) {
                                            //변화된 id값 감지
                                              phone = value;
                                          })),
                                ],
                              ),
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
                                  child: RaisedButton(
                                    onPressed: () {
                                      FindIdViewModel.findId(_name, _phone);
                                    },
                                    child: const Text(
                                      "확인",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                    color: const Color.fromARGB(
                                        255, 0, 104, 166),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 0, 104, 166)),
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
                                      "닫기",
                                      style: TextStyle(
                                          fontSize: 16, color: Color.fromARGB(
                                          255, 0, 104, 166)),
                                    ),
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 0, 104, 166)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ) ),
                ))
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}

