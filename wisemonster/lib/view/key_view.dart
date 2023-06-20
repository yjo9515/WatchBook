import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view/addkey_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/widgets/AlertWidget.dart';
import 'package:wisemonster/view/widgets/H1.dart';

import '../api/api_services.dart';

class key_view extends GetView<KeyView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<KeyView>(
        init: KeyView(),
    builder: (KeyView) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home:Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
        centerTitle: true,
        title: Text('게스트 키', style: TextStyle(
            color: Color.fromARGB(255, 44, 95, 233),
            fontWeight: FontWeight.bold,
            fontSize: 20)),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.to(addkey_view(),arguments: 'create');
              },
              child: Text(
                '추가',
                style: TextStyle(color: Color.fromARGB(255, 44, 95, 233), fontSize: 17),
              ))
        ],
      ),
      body:KeyView.isclear == false ? Center(child: CircularProgressIndicator(),)
    : Container(
        margin: EdgeInsets.fromLTRB(16, 40, 16, 0),
        width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
        height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '발급된 게스트 키',
              style: TextStyle(color: Color.fromARGB(255, 87, 132, 255), fontSize: 14),
            ),
            Expanded(
                child:ListView.builder(
                    itemCount: KeyView.listData['lists'].length == 0 ? 0 : KeyView.listData['lists'].length,
                    itemBuilder: (BuildContext context, int index){
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0,
                                blurRadius: 1,
                                offset: Offset(0, 2), // changes position of shadow
                              )
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(100))),
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Container(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.pattern_sharp,
                                      size: 32, color: Color.fromARGB(255, 255, 255, 255)),
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 87, 132, 255),
                                      borderRadius: BorderRadius.all(Radius.circular(120)))
                              ),
                             Container(width: 10,),
                              Expanded(
                                flex: 40,
                                  child:Text(
                                    '일회용 게스트 키',
                                    style: TextStyle(
                                      fontSize: 14,

                                    ),
                                  )
                              )
                              ,
                              Expanded(
                                flex: 20,
                                  child: Container(
                                width: 0,
                                height:50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(onPressed: (){
                                      Get.dialog(
                                          AlertDialog(
                                            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                            //Dialog Main Title
                                            //
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                H1(
                                                  changeValue: '시작 일시',
                                                  size: 12,
                                                ),
                                                Text(
                                                  '${KeyView.listData['lists'][index]['startDate'].toString()}',
                                                ),
                                                Container(
                                                  height: 10,
                                                ),
                                                H1(
                                                  changeValue: '종료 일시',
                                                  size: 12,
                                                ),
                                                Text(
                                                  '${KeyView.listData['lists'][index]['stopDate'].toString()}',
                                                ),
                                                Container(
                                                  height: 10,
                                                ),
                                                H1(
                                                  changeValue: '비밀번호',
                                                  size: 12,
                                                ),
                                                Text(
                                                  '${KeyView.listData['lists'][index]['passwd'].toString()}',
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text("확인"),
                                                onPressed: () {
                                                  Get.back();
                                                },
                                              ),
                                            ],
                                          )
                                      );
                                    },
                                        icon:Icon(Icons.info_outline,
                                            size: 32, color: Color.fromARGB(255, 44, 95, 233))
                                    ),
                                    // IconButton(onPressed: (){},
                                    //     icon:Image.asset(
                                    //       'images/icon/pencil.png',
                                    //       fit: BoxFit.contain,
                                    //       alignment: Alignment.center,
                                    //     )
                                    // ),
                                    IconButton(onPressed: (){
                                      KeyView.deleteKey(index);
                                    },
                                        icon:Icon(Icons.cancel_outlined,
                                            size: 32, color: Color.fromARGB(255, 44, 95, 233))
                                    )
                                  ],
                                ),
                              ))
                              ,
                            ],
                          ),
                      );
                    }
                )
            ),
          ],
        ),
      ),
    )));
  }
}
class KeyView extends GetxController{
  ApiServices api = ApiServices();
  bool isclear = false;
  var listData;
  @override
  void onInit() {
    requestKey();
    update();
    super.onInit();
  }

  deleteKey(index){
    print(listData['lists'][index]['smartdoor_guestkey_id']);
    api.delete('/SmartdoorGuestKey/${listData['lists'][index]['smartdoor_guestkey_id']}').then((value) {
      if (value['result'] == false) {
        Get.snackbar(
          '알림',
          value['message']
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      } else {
        requestKey();
        Get.snackbar(
          '알림',
          '삭제되었습니다.'
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }
    });
  }

  requestKey() {
    print(Get.arguments);
    api.get('/SmartdoorGuestkey/lists').then((value) async {
      if(value.statusCode == 200) {
        listData = json.decode(value.body);
        print(listData['lists'].length);
        print('요청한 리스트값 ${json.decode(value.body)}');
        isclear = true;
        update();
      }else if(value.statusCode == 401) {
        Get.offAll(login_view());
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }else {
        print('ddddddddfdf');
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }
    });
  }
}