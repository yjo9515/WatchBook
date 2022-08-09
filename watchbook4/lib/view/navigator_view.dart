
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/navigator_controller.dart';
import 'package:watchbook4/view/login_view.dart';
import 'package:watchbook4/view/intro_view.dart';

class navigator_view extends GetView<NavigatorController>{

  navigator_view({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
              width:
              MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
              height:
              MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .height,
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
                      width: 218,
                      height: 34,
                      alignment: Alignment.centerLeft,
                      child:  Image.network('https://watchbook.tv/image/app/default/logo.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                      ), //title text
                  ),
                  Container(
                    height: 200,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '처음 오셨나요?',
                          style:
                          TextStyle(color: Colors.white, fontSize: 40),
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
                                    Get.to(() => intro_view());
                                  },
                                  child: const Text(
                                    "네, 처음이에요.",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  color: const Color.fromARGB(
                                      97, 255, 255, 255),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 48,
                                width: double.infinity,
                                child: RaisedButton(
                                  onPressed: () {
                                    Get.to(() => login_view());
                                  },
                                  child: const Text(
                                    "아뇨, 로그인할게요.",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  color: const Color.fromARGB(
                                      97, 255, 255, 255),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ));
  }
  Future<bool> _goBack(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('와치북을 종료하시겠어요?'),
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