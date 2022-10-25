import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/controller/newMember_controller.dart';
import 'package:wisemonster/view/widgets/H1.dart';

class registration2_view extends GetView<NewMemberController>{

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              backgroundColor: Color.fromARGB(255, 42, 66, 91),
              iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
              title:
              Container(
                width: 132,
                height: 20,
                child: Image.asset(
                  'images/default/w_logo.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                ),
              )
          ),
          resizeToAvoidBottomInset: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                  width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                      .size
                      .width,
                  //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                  height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                      .size
                      .height- 186,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQueryData.fromWindow(
                            WidgetsBinding.instance!.window)
                            .size
                            .width,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                H1(changeValue: 'STEP',size: 20,),
                                H1(changeValue: '2/2',size: 20,),
                              ],
                            ),
                            Container(height: 10,),
                            Text('아래 wi-fi 연결 버튼을 누르고 미러 안내 화면에 표시된\n와이즈 몬스터 wi-fi에 연결 후 다음을 누르세요.'
                            ,style: TextStyle(
                                fontSize: 15,
                                height: 1.5
                              ),
                            ),
                            Container(height: 148,),
                            Container(
                              width: double.infinity,
                              height: 60,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                    side: BorderSide(
                                        color: Color.fromARGB(
                                          255, 18, 136, 248,),
                                        width: 1
                                    )
                                ),
                                onPressed: AppSettings.openWIFISettings,
                                icon: Icon(
                                  Icons.wifi,
                                  size: 20,
                                  color: Color.fromARGB(
                                      255, 18, 136, 248),
                                ),
                                label: Text(
                                    'wi-fi 연결',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Color.fromARGB(
                                          255, 18, 136, 248),
                                    )
                                ),
                              ),
                            ),
                            Container(height: 20,),
                            Container(
                              width: double.infinity,
                              child: Text('버튼을 누르면 와이파이 설정으로 이동합니다.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
              Container(
                  height: 60,
                  child:SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(registration2_view());
                      },
                      child: const Text(
                        "다음",
                        style: TextStyle(
                            fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 39, 161, 220),
                      ),
                    ),
                  )
              )
            ],
          ),
        ));

  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }


}