import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:watchbook4/controller/home_controller.dart';
import 'package:watchbook4/view_model/home_view_model.dart';

class home_view extends GetView<HomeController> {
  WebViewController? _webViewController;
  final Completer<WebViewController> _controllerCompleter = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeViewModel>(
        init: HomeViewModel(),
        builder: (HomeViewModel) => WillPopScope(
            onWillPop: () => _goBack(context),
            child: Scaffold(
              // floatingActionButton: FloatingActionButton(
              //   onPressed: HomeViewModel.getImage,
              //   child: Icon(Icons.add_a_photo),
              // ),
              resizeToAvoidBottomInset: false,
              body: WebView(
                key: UniqueKey(),
                initialUrl: 'https://app.watchbook.tv',
                onWebViewCreated: (WebViewController webViewController) {
                  _controllerCompleter.future.then((value) => _webViewController = value);
                  _controllerCompleter.complete(webViewController);
                },
                javascriptMode: JavascriptMode.unrestricted,
                // child: HomeViewModel.image != null ? Image.file(HomeViewModel.image) : Text('이미지 없음'),
              ),
              appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 68, 68, 68),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
                title: IconButton(
                  hoverColor: Color.fromARGB(255, 68, 68, 68),
                  autofocus: true,
                  padding: EdgeInsets.zero,
                  iconSize: 120,
                  icon: Image.network(
                    'https://watchbook.tv/image/landing/h_logo.png',
                    width: 120,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  onPressed: () {
                    _webViewController!.loadUrl('https://app.watchbook.tv');
                  },
                ),
                centerTitle: false,
              ),
              endDrawer: SafeArea(
                child: Container(
                  width: double.infinity,
                  child: Drawer(
                    child: ListView(
                      //메모리 문제해결
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      padding: EdgeInsets.zero, // 여백x
                      children: [
                        Container(
                            height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 50,
                                        padding: const EdgeInsets.fromLTRB(15, 5, 0, 0),
                                        decoration: const BoxDecoration(
                                          color: Color.fromARGB(255, 68, 68, 68),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              hoverColor: Color.fromARGB(255, 68, 68, 68),
                                              autofocus: true,
                                              padding: EdgeInsets.zero,
                                              iconSize: 120,
                                              icon: Image.network(
                                                'https://watchbook.tv/image/landing/h_logo.png',
                                                width: 120,
                                                height: 24,
                                                fit: BoxFit.contain,
                                              ),
                                              onPressed: () {
                                                _webViewController!.loadUrl('https://app.watchbook.tv');
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            IconButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              color: Color.fromARGB(255, 255, 255, 255),
                                              icon: Icon(
                                                Icons.close,
                                                size: 24,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(255, 68, 68, 68),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.5 - 0.5,
                                                height: 60,
                                                child: TextButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all(Color.fromARGB(255, 68, 68, 68))),
                                                  onPressed: () {},
                                                  child: const Text(
                                                    '내 정보',
                                                    style: TextStyle(
                                                        color: Colors.white, fontSize: 17, fontFamily: 'ONE_Regular'),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 1,
                                                height: 14,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.5 - 0.5,
                                                height: 60,
                                                child: TextButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all(Color.fromARGB(255, 68, 68, 68))),
                                                  onPressed: () async {
                                                    HomeViewModel.logoutProcess();
                                                  },
                                                  child: const Text(
                                                    '로그아웃',
                                                    style: TextStyle(
                                                        color: Colors.white, fontSize: 17, fontFamily: 'ONE_Regular'),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(color: Color.fromARGB(255, 68, 68, 68), boxShadow: [
                                    BoxShadow(
                                        color: Color.fromARGB(84, 0, 0, 0).withOpacity(0.6),
                                        spreadRadius: 0,
                                        blurRadius: 5.0,
                                        offset: Offset(0, 0))
                                  ]),
                                  height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 110,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        visualDensity: VisualDensity(vertical: 3),
                                        tileColor: Color.fromARGB(255, 68, 68, 68),
                                        dense: true,
                                        title: Center(
                                          child: const Text('수강신청',
                                              style: TextStyle(
                                                  color: Color.fromARGB(255, 255, 255, 255),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'ONE_Title')),
                                        ),
                                        onTap: () => {
                                          _webViewController!.loadUrl('https://app.watchbook.tv/studing/'),
                                          Navigator.of(context).pop()
                                        },
                                      ),
                                      ListTile(
                                        visualDensity: VisualDensity(vertical: 3),
                                        tileColor: Color.fromARGB(255, 68, 68, 68),
                                        dense: true,
                                        title: Center(
                                          child: const Text('나의클래스',
                                              style: TextStyle(
                                                  color: Color.fromARGB(255, 255, 255, 255),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'ONE_Title')),
                                        ),
                                        onTap: () => {
                                          _webViewController!.loadUrl('https://app.watchbook.tv/studing_order/list'),
                                          Navigator.of(context).pop()
                                        },
                                      ),
                                      ListTile(
                                        visualDensity: VisualDensity(vertical: 3),
                                        tileColor: Color.fromARGB(255, 68, 68, 68),
                                        dense: true,
                                        title: Center(
                                          child: const Text('나도교사',
                                              style: TextStyle(
                                                  color: Color.fromARGB(255, 255, 255, 255),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'ONE_Title')),
                                        ),
                                        onTap: () => {
                                          _webViewController!.loadUrl('https://app.watchbook.tv/classroom/index'),
                                          Navigator.of(context).pop()
                                        },
                                      ),
                                      ListTile(
                                        visualDensity: VisualDensity(vertical: 3),
                                        tileColor: Color.fromARGB(255, 68, 68, 68),
                                        dense: true,
                                        title: Center(
                                          child: const Text('나는부모',
                                              style: TextStyle(
                                                  color: Color.fromARGB(255, 255, 255, 255),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'ONE_Title')),
                                        ),
                                        onTap: () => {
                                          _webViewController!.loadUrl('https://app.watchbook.tv/parent/index'),
                                          Navigator.of(context).pop()
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await _webViewController!.canGoBack()) {
      _webViewController?.goBack();
      return Future.value(false);
    } else {
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
}
