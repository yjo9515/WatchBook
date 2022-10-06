import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/controller/home_controller.dart';
import 'package:wisemonster/view_model/findPw_view_model.dart';

class findPw_view extends GetView<HomeController>{
  findPw_view({Key? key}) : super(key: key);
  String phone = '';
  String id = '';
  var _phone = TextEditingController();
  var _id = TextEditingController();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetBuilder<FindPwViewModel>(
        init: FindPwViewModel(),
        builder: (FindPwViewModel) =>
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
                                    '비밀번호 찾기',
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
                                      '아이디를 입력해주세요.',
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
                                          controller: _id, //set id controller
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 206, 206, 206), fontSize: 16),
                                          decoration: const InputDecoration(
                                              hintText: '아이디',
                                              hintStyle: TextStyle(color: Color.fromARGB(
                                                  255, 206, 206, 206)),
                                              border: InputBorder.none
                                          ),
                                          onChanged: (value) {
                                            //변화된 id값 감지
                                            id = value;
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
                                            //변화된 pw값 감지
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

                                ),
                                SizedBox(
                                  height: 48,
                                  width: double.infinity,

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