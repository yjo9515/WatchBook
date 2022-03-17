import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/newMember_controller.dart';
import 'package:watchbook4/view/agreement_view.dart';
import 'package:watchbook4/view/newMember3_view.dart';
import 'package:watchbook4/view_model/newMem_view_model.dart';

class newMember2_view extends GetView<NewMemberController>{
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewMemberViewModel>(
        init: NewMemberViewModel(),
    builder: (NewMemberViewModel) =>
        WillPopScope(
            onWillPop: () => _goBack(context),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Container(
                  padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                  width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                      .size
                      .width,
                  //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                  height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                      .size
                      .height,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
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
                                    child: const Text('01',
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
                                    '이용 약관 동의',
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
                        child:SingleChildScrollView(
                            child:Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 207, 207, 207)
                                          )
                                      )
                                  ),
                                  child: SizedBox(
                                    width: MediaQueryData.fromWindow(
                                        WidgetsBinding.instance!.window)
                                        .size
                                        .width,
                                    height: 58,
                                    child: TextButton.icon(
                                      onPressed: (){
                                        NewMemberViewModel.agreeChange();
                                      },
                                      label: Align(
                                        alignment: Alignment.centerRight,
                                        child: NewMemberViewModel.isAgree && NewMemberViewModel.isEmailAgree && NewMemberViewModel.isSMSAgree? Image.network('https://watchbook.tv/image/app/newmem/select.png',
                                          width: 28,
                                          height: 28,
                                        ) : Image.network('https://watchbook.tv/image/app/newmem/off.png',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                      icon: const Text('모든 약관 확인,동의합니다.',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 0, 0, 0)  ,
                                            fontSize: 20
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  width: MediaQueryData.fromWindow(
                                      WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  height: 146,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: NewMemberViewModel.isAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                          255, 207, 207, 207), width: 1)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: MediaQueryData.fromWindow(
                                            WidgetsBinding.instance!.window)
                                            .size
                                            .width,
                                        child: TextButton.icon(
                                          onPressed: (){
                                            NewMemberViewModel.agreeChange2();
                                          },
                                          label: Align(
                                            alignment: Alignment.centerRight,
                                            child: NewMemberViewModel.isAgree ? Image.network('https://watchbook.tv/image/app/newmem/select.png',
                                              width: 28,
                                              height: 28,
                                            ) : Image.network('https://watchbook.tv/image/app/newmem/off.png',
                                              width: 28,
                                              height: 28,
                                            ),
                                          ),
                                          icon: Text('이용약관 전체동의 [필수]',
                                            style: TextStyle(
                                                color: NewMemberViewModel.isAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                                    255, 0, 0, 0) ,
                                                fontSize: 16
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQueryData.fromWindow(
                                            WidgetsBinding.instance!.window)
                                            .size
                                            .width,
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            minimumSize: const Size(5,16),
                                          ),
                                          onPressed: () async {
                                            NewMemberViewModel.isAgree = await
                                            Get.to(agreement_view());
                                            print(NewMemberViewModel.isAgree);
                                          },
                                          label: const Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons.navigate_next,size:20,color:Color.fromARGB(
                                                  255, 207, 207, 207) ,
                                              )
                                          ),
                                          icon: const Text('[필수] 온라인 회원 약관 동의',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 207, 207, 207) ,
                                                fontSize: 14
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQueryData.fromWindow(
                                            WidgetsBinding.instance!.window)
                                            .size
                                            .width,
                                        child: TextButton.icon(
                                          onPressed: () async {
                                            NewMemberViewModel.isAgree = await
                                            Get.to(agreement_view());
                                            print(NewMemberViewModel.isAgree);
                                          },
                                          label: const Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons.navigate_next,size:20,color:Color.fromARGB(
                                                  255, 207, 207, 207) ,
                                              )
                                          ),
                                          icon: const Text('[필수] 개인정보 수집 및 이용 안내 동의',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 207, 207, 207) ,
                                                fontSize: 14
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 5),
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  width: MediaQueryData.fromWindow(
                                      WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: NewMemberViewModel.isEmailAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                          255, 207, 207, 207), width: 1)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: MediaQueryData.fromWindow(
                                            WidgetsBinding.instance!.window)
                                            .size
                                            .width,
                                        child: TextButton.icon(
                                          onPressed: (){
                                              NewMemberViewModel.agreeChange3();
                                          },
                                          label: Align(
                                            alignment: Alignment.centerRight,
                                            child: NewMemberViewModel.isEmailAgree ? Image.network('https://watchbook.tv/image/app/newmem/select.png',
                                              width: 28,
                                              height: 28,
                                            ) : Image.network('https://watchbook.tv/image/app/newmem/off.png',
                                              width: 28,
                                              height: 28,
                                            ),
                                          ),
                                          icon: Text('이메일 수신 동의 [선택]',
                                            style: TextStyle(
                                                color: NewMemberViewModel.isEmailAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                                    255, 0, 0, 0) ,
                                                fontSize: 16
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQueryData.fromWindow(
                                            WidgetsBinding.instance!.window)
                                            .size
                                            .width,
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            minimumSize: const Size(5,16),
                                          ),
                                          onPressed: (){

                                          },
                                          label: const Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons.navigate_next,size:20,color:Color.fromARGB(
                                                  255, 207, 207, 207) ,
                                              )
                                          ),
                                          icon: const Text('[선택] 안내 메일 수신 동의',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 207, 207, 207) ,
                                                fontSize: 14
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  width: MediaQueryData.fromWindow(
                                      WidgetsBinding.instance!.window)
                                      .size
                                      .width,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: NewMemberViewModel.isSMSAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                          255, 207, 207, 207), width: 1)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: MediaQueryData.fromWindow(
                                            WidgetsBinding.instance!.window)
                                            .size
                                            .width,
                                        child: TextButton.icon(
                                          onPressed: (){
                                            NewMemberViewModel.smsAgree();
                                          },
                                          label: Align(
                                            alignment: Alignment.centerRight,
                                            child: NewMemberViewModel.isSMSAgree ? Image.network('https://watchbook.tv/image/app/newmem/select.png',
                                              width: 28,
                                              height: 28,
                                            ) : Image.network('https://watchbook.tv/image/app/newmem/off.png',
                                              width: 28,
                                              height: 28,
                                            ),
                                          ),
                                          icon: Text('SMS 수신 동의 [선택]',
                                            style: TextStyle(
                                                color: NewMemberViewModel.isSMSAgree ? const Color.fromARGB(255, 0, 104, 166) : const Color.fromARGB(
                                                    255, 0, 0, 0) ,
                                                fontSize: 16
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQueryData.fromWindow(
                                            WidgetsBinding.instance!.window)
                                            .size
                                            .width,
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            minimumSize: const Size(5,16),
                                          ),
                                          onPressed: (){

                                          },
                                          label: const Align(
                                              alignment: Alignment.centerRight,
                                              child: Icon(
                                                Icons.navigate_next,size:20,color:Color.fromARGB(
                                                  255, 207, 207, 207) ,
                                              )
                                          ),
                                          icon: const Text('[선택] 온라인 회원 약관 동의',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 207, 207, 207) ,
                                                fontSize: 14
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                        ),
                      ),
                      Container(
                        height: 106,
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
                                  if(NewMemberViewModel.isAgree){
                                    Get.to(newMember3_view());
                                  } else {
                                    NewMemberViewModel.dialog();
                                  }
                                },
                                child: const Text(
                                  "다음으로",
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
                                  "이전으로",
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
                  )),
            ))
    );
  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
  
  
}