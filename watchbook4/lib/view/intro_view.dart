import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/home_controller.dart';
import 'package:watchbook4/view/newMember1_view.dart';

class intro_view extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.fromLTRB(0, 90, 0, 20),
              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
              //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
              height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://watchbook.tv/image/app/default/background.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: const Text(
                      '와치북만의 특별한 기능!',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  ),
                  Container(
                    height: 370,
                    margin: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                          padding: const EdgeInsets.fromLTRB(20, 20, 40, 20),
                          child: const Text(
                            '맞춤 수준의 교육컨텐츠',
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                          decoration: const BoxDecoration(
                              color: const Color.fromARGB(97, 0, 36, 98),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              )),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                          padding: const EdgeInsets.fromLTRB(20, 20, 40, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                '다양한 보충 학습,',
                                style: TextStyle(fontSize: 30, color: Colors.white),
                              ),
                              Text(
                                '반복 알고리즘',
                                style: TextStyle(fontSize: 30, color: Colors.white),
                              ),
                            ],
                          ),
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(97, 0, 36, 98),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(60),
                                bottomRight: Radius.circular(60),
                              )),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                          padding: const EdgeInsets.fromLTRB(20, 20, 40, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                '서술형 채점결과를',
                                style: TextStyle(fontSize: 30, color: Colors.white),
                              ),
                              Text(
                                '빠르고 간단하게!',
                                style: TextStyle(fontSize: 30, color: Colors.white),
                              ),
                            ],
                          ),
                          decoration: const BoxDecoration(
                              color: const Color.fromARGB(97, 0, 36, 98),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(60),
                                bottomRight: Radius.circular(60),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          Get.to(() => newMember1_view());
                        },
                        child: const Text(
                          "다음으로",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        color: const Color.fromARGB(97, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ));
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}
