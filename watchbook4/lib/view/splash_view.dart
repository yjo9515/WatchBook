import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/home_controller.dart';
import 'package:watchbook4/view/login_view.dart';

class splash_view extends GetView<HomeController>{
  const splash_view({Key? key}) : super(key: key);
  @override

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 72),
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
                image:  DecorationImage(
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
                      ),//title text
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Text(
                          '지루한 공부,',
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                        Text(
                          '와치북과',
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                        Text(
                          '즐겁고 재밌게.',
                          style: TextStyle(color: Colors.white, fontSize: 40),
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ));
    throw UnimplementedError();
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