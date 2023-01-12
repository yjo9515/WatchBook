
import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'dart:math';

class addMember_view extends GetView<MemberController> {

  List<Contact>? contacts;
  getPermission() async{
    var status = await Permission.contacts.status;
    if(status.isGranted){
      print('허락됨');
      // 변수 가져오기!
      contacts = await ContactsService.getContacts();
      for(var i=0; i<contacts!.length; i++){
        print(inspect(contacts![i].phones?.first.value));
      }
      print(contacts![0].displayName);
      return contacts;
    } else if (status.isDenied){
      print('거절됨');
      Permission.contacts.request(); // 허락해달라고 팝업띄우는 코드
    }
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MemberController>(
        init: MemberController(),
        builder: (KeyViewModel) => Scaffold(
            resizeToAvoidBottomInset : false,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
                leading: IconButton(
                  onPressed: () => Get.back(),
                  color: Color.fromARGB(255, 0000000000000000000000000018, 136, 248),
                  icon: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    size: 20,
                  ),
                ),
                centerTitle: true,
                title: Text(
                '초대하기',
                    style:
                        TextStyle(color: Color.fromARGB(255, 44, 95, 233), fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 40, 16, 0),
                    width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                    height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 186,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        H1(changeValue: '호칭', size: 14,),
                        Container(height: 20,),
                      TextFieldWidget(
                          tcontroller: KeyViewModel.namecontroller,
                          changeValue: KeyViewModel.name,
                          hintText: '받으시는 분 호칭을 입력해주세요.'),
                        Container(height: 30,),
                        H1(changeValue: '휴대폰번호', size: 14,),
                        Row(children: [
                          Expanded(
                              flex: 66,
                              child: TextFieldWidget(
                                  tcontroller: KeyViewModel.phonecontroller,
                                  changeValue: KeyViewModel.phone,
                                  hintText: '휴대폰번호를 입력해주세요.')),
                          Container(width: 20,),
                          Expanded(
                              flex: 27,
                              child: TextButton(
                                onPressed: () {
                                  Get.dialog(AlertDialog(
                                    // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                    //Dialog Main Title
                                    title: Container(
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [Text("연락처 목록")],
                                      ),
                                    ),
                                    //
                                    content:
                                    FutureBuilder(
                                        future: getPermission(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Container(
                                              height: 300.0, // Change as per your requirement
                                              width: 300.0, // Change as per your requirement
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: contacts!.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return ListTile(
                                                    title: Text('${contacts![index].displayName}'),
                                                    subtitle: Text('${contacts![index].phones?.first.value}'),
                                                    onTap: (){
                                                      print(contacts![index].phones?.first.value);
                                                      Get.put(MemberController()).updateContact(contacts![index].phones?.first.value);
                                                    },
                                                  );
                                                },
                                              ),
                                            );
                                          } else {
                                            return
                                              Container(
                                                width: 100,
                                                height: 150,
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children:[
                                                      SizedBox
                                                        (
                                                        width: 50,
                                                        height: 50,
                                                        child: CircularProgressIndicator(
                                                        ),
                                                      )
                                                    ]
                                                ),
                                              )
                                            ;
                                          }
                                        }),
                                    actions: <Widget>[

                                    ],
                                  ));
                                  print('호출');
                                },
                                child: Text('주소록', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 14)),
                                style: TextButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 87, 132, 255),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                              )),
                        ]),




                      ],
                    ),
                  ),
                  Container(
                      height: 60,
                      child:SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {

                          },
                          child: Text(
                            '초대',
                            style: TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 87, 132, 255),
                          ),
                        ),
                      )
                  )
                ],
              )
            ));
  }
}
