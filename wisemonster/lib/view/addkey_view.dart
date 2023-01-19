
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/widgets/ContactListWidget.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:wisemonster/view_model/key_view_model.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';
import '../controller/member_controller.dart';
import 'widgets/LeftSlideWidget.dart';
import 'dart:math';

class addkey_view extends GetView<KeyViewModel> {


  @override
  Widget build(BuildContext context) {
    return GetBuilder<KeyViewModel>(
        init: KeyViewModel(),
        builder: (KeyViewModel) => Scaffold(
            resizeToAvoidBottomInset : false,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
                leading: IconButton(
                  onPressed: () => Get.offAll(home_view()),
                  color: Color.fromARGB(255, 0000000000000000000000000018, 136, 248),
                  icon: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    size: 20,
                  ),
                ),
                centerTitle: true,
                title: Text(
                '게스트 키 발급',
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
                                  Get.dialog(ContactListWidget());
                                  print('호출');
                                },
                                child: Text('주소록', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 14)),
                                style: TextButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 87, 132, 255),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                              )),
                        ]),
                        Container(height: 30,),
                        H1(changeValue: '기간설정', size: 14,),
                        Row(
                          children: [
                            Expanded(
                              flex: 43,
                              child:
                              TextField(
                                controller: KeyViewModel.startController, //editing controller of this TextField
                                decoration: InputDecoration(
                                    icon: Icon(Icons.calendar_month_outlined), //icon of text field
                                    labelText: "시작일" //label text of field
                                ),
                                readOnly: true, //set it true, so that user will not able to edit text
                                onTap: () async {
                                  KeyViewModel.pickedStartDate = (await showDatePicker(
                                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2101)))!;
                                  KeyViewModel.selectDate(0);
                                },
                              ),
                            ),
                            Expanded(
                                flex: 12,
                                child:
                                Center(
                                  child: Text('~'),
                                )
                            ),
                            Expanded(
                              flex: 43,
                              child: TextField(
                                controller: KeyViewModel.endController, //editing controller of this TextField
                                decoration: InputDecoration(
                                    icon: Icon(Icons.calendar_month_outlined), //icon of text field
                                    labelText: "종료일" //label text of field
                                ),
                                readOnly: true, //set it true, so that user will not able to edit text
                                onTap: () async {
                                  KeyViewModel.pickedEndDate = (await showDatePicker(
                                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2101)))!;
                                  KeyViewModel.selectDate(1);
                                },
                              ),
                            )
                          ],
                        ),
                        Container(height: 30,),
                        H1(changeValue: '시간설정', size: 14,),
                        Row(
                          children: [
                            Expanded(
                              flex: 43,
                              child:
                              TextField(
                                controller: KeyViewModel.startTimeController, //editing controller of this TextField
                                decoration: InputDecoration(
                                    icon: Icon(Icons.timer), //icon of text field
                                    labelText: "시작 시간" //label text of field
                                ),
                                readOnly: true, //set it true, so that user will not able to edit text
                                onTap: () async {
                                  KeyViewModel.selectedStartTime =
                                  (showTimePicker(context: context,
                                      initialEntryMode: TimePickerEntryMode.inputOnly,
                                      initialTime: TimeOfDay.now()))!;
                                  KeyViewModel.selectedStartTime.then((timeOfDay) {
                                    KeyViewModel.selectTime(0,timeOfDay);
                                  }
                                  );
                                },
                              ),
                            ),
                            Expanded(
                                flex: 12,
                                child:
                                Center(
                                  child: Text('~'),
                                )
                            ),
                            Expanded(
                              flex: 41,
                              child:
                              TextField(
                                controller: KeyViewModel.endTimeController, //editing controller of this TextField
                                decoration: InputDecoration(
                                    icon: Icon(Icons.timer), //icon of text field
                                    labelText: "종료 시간" //label text of field
                                ),
                                readOnly: true, //set it true, so that user will not able to edit text
                                onTap: () async {
                                  KeyViewModel.selectedEndTime =
                                  (showTimePicker(
                                      initialEntryMode: TimePickerEntryMode.inputOnly,
                                      context: context, initialTime: TimeOfDay.now()))!;
                                  KeyViewModel.selectedEndTime.then((timeOfDay) {
                                    KeyViewModel.selectTime(1,timeOfDay);
                                  }
                                  );
                                },
                              ),
                            ),

                          ],
                        ),
                        Container(height: 30,),
                        H1(changeValue: '일회용 비밀번호', size: 14,),
                        TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            maxLength: 6,
                            controller: KeyViewModel.passwdController, //set id controller
                            style: const TextStyle(
                                color: Color.fromARGB(255, 43, 43, 43), fontSize: 17),
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Color.fromARGB(255, 43, 43, 43))),
                            ),

                            onChanged: (value) {
                              //변화된 id값 감지
                              KeyViewModel.pw = value;
                              print(value);
                            }),
                        Container(height: 30,),
                        Center(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  maximumSize: Size(246, 40),
                                  backgroundColor: Color.fromARGB(255, 87, 132, 255)
                              ),
                              onPressed: (){
                                List<int> nums = [];

                                for( int i = 0; i < 6; i ++) {
                                  nums.add(Random().nextInt(9));
                                }
                                KeyViewModel.passwdController.text = nums[0].toString()+nums[1].toString()+nums[2].toString()+nums[3].toString()+nums[4].toString()+nums[5].toString();
                              },
                              child:Center(
                                child: Text('일회용 비밀번호 생성',
                                  style: TextStyle(
                                      fontSize: 14
                                  ),
                                ),
                              )
                          ),
                        )

                      ],
                    ),
                  ),
                  Container(
                      height: 60,
                      child:SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            KeyViewModel.createKey();
                          },
                          child: Text(
                            '발급하기',
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
