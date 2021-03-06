import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/newMember_controller.dart';
import 'package:watchbook4/view_model/newMem_view_model.dart';

class newMember3_view extends GetView<NewMemberController>{
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
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
                                          child: const Text('02',
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
                                          '휴대폰 인증',
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
                                      '휴대폰 번호를 입력해주세요.',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                    decoration: const BoxDecoration(
                                        color: const Color.fromARGB(
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
                                          controller: NewMemberViewModel.nameController, //set id controller
                                          style: const TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 206, 206, 206), fontSize: 16),
                                          decoration: const InputDecoration(
                                              hintText: '성명을 입력해 주세요.',
                                              hintStyle: TextStyle(color: const Color.fromARGB(
                                                  255, 206, 206, 206)),
                                              border: InputBorder.none
                                          ),
                                          onChanged: (value) {
                                            //변화된 id값 감지
                                            NewMemberViewModel.name = value;
                                          })),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                            flex : 74,
                                            child:Container(
                                              padding: const EdgeInsets.only(left: 20),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: const Color.fromARGB(
                                                          255, 206, 206, 206)
                                                  )
                                              ),
                                              child:  TextField(
                                                  controller: NewMemberViewModel.phoneController, //set id controller
                                                  style: const TextStyle(
                                                      color: const Color.fromARGB(
                                                          255, 206, 206, 206), fontSize: 16),
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: '- 없이 입력해주세요.',
                                                    hintStyle: TextStyle(color: const Color.fromARGB(
                                                        255, 206, 206, 206)),
                                                  ),
                                                  onChanged: (value) {
                                                    //변화된 id값 감지
                                                    NewMemberViewModel.phone = value;
                                                  }),
                                            )),
                                        Expanded(
                                            flex: 26,
                                            child: RaisedButton(onPressed:requestSendAuthProcess,
                                              padding: const EdgeInsets.fromLTRB(0, 17, 0, 17),
                                              child:
                                              NewMemberViewModel.send ? const Text('재전송',
                                                style: TextStyle
                                                  (color: const Color.fromARGB(
                                                    255, 255, 255, 255)
                                                    ,fontSize: 16),
                                              ) :
                                              const Text('전송',
                                                  style: TextStyle
                                                    (color: const Color.fromARGB(
                                                      255, 255, 255, 255)
                                                      ,fontSize: 16)),
                                              color: const Color.fromARGB(
                                                  255, 108, 158, 207),
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.zero
                                              ),
                                            )
                                        )],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                    child: send ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                            flex : 55,
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 20),
                                              decoration: const BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 206, 206, 206),
                                                    ),
                                                    left: BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 206, 206, 206),
                                                    ),
                                                    bottom: BorderSide(
                                                      color: Color.fromARGB(
                                                          255, 206, 206, 206),
                                                    ),
                                                  )
                                              ),
                                              child: TextField(
                                                  controller: _phoneAuth, //set id controller
                                                  style: const TextStyle(
                                                      color: const Color.fromARGB(
                                                          255, 206, 206, 206), fontSize: 16),
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: '인증번호를 입력해주세요.',
                                                    hintStyle: TextStyle(color: const Color.fromARGB(
                                                        255, 206, 206, 206)),
                                                  ),
                                                  onChanged: (value) {
                                                    //변화된 id값 감지
                                                    phoneAuth = value;
                                                  }),
                                            )),
                                        Expanded(
                                            flex: 19,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  border: Border(
                                                      top: BorderSide(
                                                        color: Color.fromARGB(
                                                            255, 206, 206, 206),
                                                      ),
                                                      bottom: BorderSide(
                                                        color: Color.fromARGB(
                                                            255, 206, 206, 206),
                                                      )
                                                  )
                                              ),
                                              padding:const EdgeInsets.fromLTRB(13, 16, 10, 16) ,
                                              child: Text(timedisplay,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 255, 0, 0),
                                                  fontSize: 14,
                                                ),),
                                            )
                                        ),
                                        Expanded(
                                            flex: 26,
                                            child: RaisedButton(onPressed: requestCheckAuthProcess,
                                              padding: const EdgeInsets.fromLTRB(0, 17, 0, 17),
                                              child:
                                              const Text('인증',
                                                style: TextStyle
                                                  (color: const Color.fromARGB(
                                                    255, 255, 255, 255)
                                                    ,fontSize: 16),
                                              ),
                                              color: const Color.fromARGB(
                                                  255, 108, 158, 207),
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.zero
                                              ),
                                            )
                                        )],
                                    ) : null,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    height: 68,
                                    child:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        txt == 2 ?
                                        const Text('* 인증번호가 일치하지 않습니다.',
                                            style: TextStyle(
                                                color: Color.fromARGB(255, 255, 0, 0),
                                                fontSize: 14
                                            ) )
                                            :
                                        txt == 1 ?
                                        const Text('* 인증완료 되었습니다.',
                                            style: TextStyle(
                                                color: Color.fromARGB(255, 17, 255, 0),
                                                fontSize: 14
                                            ) )
                                            : const Text('', style: TextStyle(fontSize: 14),),
                                        const Text('* 입력시간 내 인증번호 6자리를 입력해주세요.',
                                          style: TextStyle(fontSize: 14),),
                                        const Text("* 인증번호가 오지 않는 경우 '재전송'을 클릭해주세요",
                                          style: TextStyle(fontSize: 14),)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
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
                                      requestCheckName();
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
                      ) ),
                ))

    );
  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
  
}