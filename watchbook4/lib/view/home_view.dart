import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watchbook4/controller/home_controller.dart';
import 'package:watchbook4/view/member_view.dart';
import 'package:watchbook4/view_model/home_view_model.dart';

class home_view extends GetView<HomeController>{
  final ImagePicker _picker = ImagePicker();
  late XFile? _image;

  
  Future _getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    _image = image;
  }
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeViewModel>(
        init: HomeViewModel(),
    builder: (HomeViewModel) =>
        WillPopScope(
            onWillPop: () => _goBack(context),
            child: Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: _getImage,
                child: Icon(Icons.add_a_photo),
              ),
              resizeToAvoidBottomInset: false,
              body: Center(
                key: UniqueKey(),
                child: _image != null ? Image.file(File(_image!.path)) : Text('이미지 없음'),

              ),
              appBar:
              AppBar(
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color:Color.fromARGB(255, 0, 104, 166)),
                title: Image.network('https://watchbook.tv/image/app/nav/logo.png',
                  width: 87,
                  height: 18,
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                      onPressed: () async {
                        HomeViewModel.logoutProcess();
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: Color.fromARGB(255, 0, 104, 166),
                      ))
                ],
              ),
              drawer: Drawer(
                child: ListView(
                  //메모리 문제해결
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  padding: EdgeInsets.zero, // 여백x
                  children: [
                    Container(
                        height: MediaQueryData.fromWindow(
                            WidgetsBinding.instance!.window)
                            .size
                            .height,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  Container(
                                    height: 128,
                                    padding: const EdgeInsets.only(top: 20),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 217, 84, 84),
                                    ),
                                    child:
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        const Expanded(child: CircleAvatar(
                                          radius: 40,
                                        ),),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              const Text('박보영 님', style: TextStyle(fontSize: 21, color: Colors.white, fontFamily: 'ONE_Title')),
                                              const Text('LV. 1', style: TextStyle(fontSize: 21, color: Colors.white,fontWeight: FontWeight.bold,fontFamily: 'ONE_Regular')),
                                              const Text('', style: TextStyle(fontSize: 10, color: Colors.white)),
                                              const Text('30 C', style: TextStyle(fontSize: 21, color: Colors.white,fontWeight: FontWeight.bold,fontFamily: 'ONE_Regular')),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      decoration: const BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                color: Color.fromARGB(255, 207, 207, 207),
                                              )
                                          )
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () {
                                                print('d');
                                              },
                                              child: const Text(
                                                '내 정보',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                    fontFamily: 'ONE_Regular'
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 14,
                                            color:
                                            const Color.fromARGB(255, 207, 207, 207),
                                          ),
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () {
                                                print('d');
                                              },
                                              child: const Text(
                                                '스토어',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                    fontFamily: 'ONE_Regular'
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                            Container(
                                height: MediaQueryData.fromWindow(
                                    WidgetsBinding.instance!.window)
                                    .size
                                    .height - 187,
                                child: SingleChildScrollView(
                                    child:Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: 544,
                                          child: Column(
                                            children: [
                                              ListTile(
                                                dense: true,
                                                title: const Text('내 강좌',
                                                    style: TextStyle(
                                                        color: const Color.fromARGB(
                                                            255, 0, 0, 0),
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                                onTap: () => {print("")},
                                                trailing: const Icon(
                                                  IconData(0xe15f,
                                                      fontFamily: 'MaterialIcons',
                                                      matchTextDirection: true),
                                                  color: const Color.fromARGB(255, 0, 0, 0),
                                                ),
                                              ),
                                              const Divider(
                                                  indent: 20,
                                                  endIndent: 20,
                                                  color: Color.fromARGB(255, 207, 207, 207)),
                                              ListTile(
                                                dense: true,
                                                title: const Text('문제은행',
                                                    style: TextStyle(
                                                        color: const Color.fromARGB(
                                                            255, 0, 0, 0),
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                                onTap: () => {print("settting")},
                                                trailing: const Icon(
                                                  IconData(0xe15f,
                                                      fontFamily: 'MaterialIcons',
                                                      matchTextDirection: true),
                                                  color: const Color.fromARGB(255, 0, 0, 0),
                                                ),
                                              ),
                                              const Divider(
                                                  indent: 20,
                                                  endIndent: 20,
                                                  color: Color.fromARGB(255, 207, 207, 207)),
                                              ListTile(
                                                dense: true,
                                                title: const Text('1:1 질문',
                                                    style: TextStyle(
                                                        color: const Color.fromARGB(
                                                            255, 0, 0, 0),
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                                onTap: () => {print("Q&A")},
                                                trailing: const Icon(
                                                    IconData(0xe15f,
                                                        fontFamily: 'MaterialIcons',
                                                        matchTextDirection: true),
                                                    color:
                                                    const Color.fromARGB(255, 0, 0, 0)),
                                              ),
                                              const Divider(
                                                  indent: 20,
                                                  endIndent: 20,
                                                  color: Color.fromARGB(255, 207, 207, 207)),
                                              ListTile(
                                                dense: true,
                                                title: const Text('친구목록',
                                                    style: TextStyle(
                                                        color: const Color.fromARGB(
                                                            255, 0, 0, 0),
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                                onTap: () async {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (BuildContext context) =>
                                                              member_view()));
                                                },
                                                trailing: const Icon(
                                                    IconData(0xe15f,
                                                        fontFamily: 'MaterialIcons',
                                                        matchTextDirection: true),
                                                    color:
                                                    const Color.fromARGB(255, 0, 0, 0)),
                                              ),
                                              const Divider(
                                                  indent: 20,
                                                  endIndent: 20,
                                                  color: Color.fromARGB(255, 207, 207, 207)),
                                              ListTile(
                                                dense: true,
                                                title: const Text('고객센터',
                                                    style: TextStyle(
                                                        color: const Color.fromARGB(
                                                            255, 0, 0, 0),
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                                onTap: () => {print("Q&A")},
                                                trailing: const Icon(
                                                    IconData(0xe15f,
                                                        fontFamily: 'MaterialIcons',
                                                        matchTextDirection: true),
                                                    color:
                                                    const Color.fromARGB(255, 0, 0, 0)),
                                              ),
                                              const Divider(
                                                  indent: 20,
                                                  endIndent: 20,
                                                  color: Color.fromARGB(255, 207, 207, 207)),
                                              ListTile(
                                                dense: true,
                                                title: const Text('도움말',
                                                    style: TextStyle(
                                                        color: const Color.fromARGB(
                                                            255, 0, 0, 0),
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.bold,fontFamily: 'ONE_Title')),
                                                onTap: () => {print("Q&A")},
                                                trailing: const Icon(
                                                    IconData(0xe15f,
                                                        fontFamily: 'MaterialIcons',
                                                        matchTextDirection: true),
                                                    color:
                                                    const Color.fromARGB(255, 0, 0, 0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                          decoration: const BoxDecoration(
                                              border: Border(
                                                  top: BorderSide(
                                                    width: 1,
                                                    color: Color.fromARGB(255, 207, 207, 207),
                                                  ))),
                                          child: Container(
                                            height: 52,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      TextButton(
                                                        child: const Text(
                                                          '이용약관',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        onPressed: () {},
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        height: 14,
                                                        color: Colors.black,
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                          '개인정보처리방침',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        onPressed: () {},
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                TextButton(
                                                  child: const Text(
                                                    '로그아웃',
                                                    style: TextStyle(
                                                        color: Color.fromARGB(255, 0, 36, 98),
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  onPressed: () async {
                                                    HomeViewModel.logoutProcess();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                )
                            ),
                          ],
                        )
                    )
                  ],
                ),
              ),
              // bottomNavigationBar:
              // Container(
              //   color: const Color.fromARGB(255, 246, 249, 249),
              //   height: 26,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       const Text('watchbook@naver.com')
              //     ],
              //   ),
              // )
            ))
    );
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