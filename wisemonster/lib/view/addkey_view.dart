import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wisemonster/view/widgets/ContactListWidget.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:wisemonster/view_model/key_view_model.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';
import '../controller/member_controller.dart';
import 'widgets/LeftSlideWidget.dart';

class addkey_view extends GetView<MemberController> {
  var phonecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KeyViewModel>(
        init: KeyViewModel(),
        builder: (KeyViewModel) => Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  color: Color.fromARGB(255, 0000000000000000000000000018, 136, 248),
                  icon: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    size: 20,
                  ),
                ),
                centerTitle: true,
                title: Text('게스트 키 발급',
                    style:
                        TextStyle(color: Color.fromARGB(255, 44, 95, 233), fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              body: Container(
                margin: EdgeInsets.fromLTRB(16, 40, 16, 0),
                width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    H1(changeValue: '휴대폰번호', size: 14,),
                    Row(children: [
                      Expanded(
                        flex: 66,
                          child: TextFieldWidget(
                              tcontroller: phonecontroller,
                              changeValue: KeyViewModel.selectName,
                              hintText: '휴대폰번호를 입력해주세요.')),
                      Container(width: 20,),
                      Expanded(
                          flex: 27,
                          child: TextButton(
                        onPressed: () {

                          Get.dialog(ContactListWidget());
                          print('호출');
                        },
                        child: Text('주소록', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 14)),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 87, 132, 255),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                      )),
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ]),
                    H1(changeValue: '기간설정', size: 14,),
                  ],
                ),
              ),
            ));
  }
}
