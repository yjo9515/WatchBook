import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/newMember_controller.dart';
import 'package:watchbook4/view/newMember2_view.dart';
import 'package:watchbook4/view_model/newMem_view_model.dart';

class newMember1_view extends GetView<NewMemberController>{

  newMember1_view({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetBuilder<NewMemberViewModel>(
        init: NewMemberViewModel(),
    builder: (NewMemberViewModel) =>WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
              height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
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
                  const Text(
                    '무엇을 하고 싶으세요?',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 136,
                            margin: const EdgeInsets.only(top: 50),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Theme(
                                    data: ThemeData(
                                        unselectedWidgetColor: Colors.transparent),
                                    child: CheckboxListTile(
                                        title: const Text(
                                          '학습을 하고 싶어요',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        value: NewMemberViewModel.isStudentChecked,
                                        onChanged: (value) {
                                          NewMemberViewModel.firstChange(value);
                                        },
                                        activeColor: Colors.transparent,
                                        // checkColor: Colors.white,
                                        isThreeLine: false,
                                        selected: NewMemberViewModel.isStudentChecked),
                                  ),
                                  decoration: BoxDecoration(
                                    color: NewMemberViewModel.isStudentChecked
                                        ? const Color.fromARGB(97, 0, 36, 98)
                                        : const Color.fromARGB(97, 255, 255, 255),
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Theme(
                                    data: ThemeData(
                                        unselectedWidgetColor: Colors.transparent),
                                    child: CheckboxListTile(
                                      title: const Text(
                                        '교육을 하고 싶어요',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      value: NewMemberViewModel.isTeacherChecked == true,
                                      onChanged: (value) {
                                         NewMemberViewModel.secondChange(value);
                                      },
                                      activeColor: Colors.transparent,
                                      // checkColor: Colors.white,
                                      isThreeLine: false,
                                      selected: NewMemberViewModel.isTeacherChecked,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: NewMemberViewModel.isTeacherChecked
                                        ? const Color.fromARGB(97, 0, 36, 98)
                                        : const Color.fromARGB(97, 255, 255, 255),
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (NewMemberViewModel.isStudentChecked == true ||
                              NewMemberViewModel.isTeacherChecked == true) {
                            if(NewMemberViewModel.isTeacherChecked == false && NewMemberViewModel.isStudentChecked == true){
                              NewMemberViewModel.joinType = '1';
                                print(NewMemberViewModel.joinType);
                            }else if(NewMemberViewModel.isTeacherChecked == true && NewMemberViewModel.isStudentChecked == false){
                              NewMemberViewModel.joinType = '2';
                                print(NewMemberViewModel.joinType);
                            }
                            Get.to(newMember2_view());
                          }
                        },
                        child: const Text(
                          "다음으로",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color.fromARGB(
                                    255, 0, 104, 166)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color.fromARGB(
                              255, 0, 104, 166),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        )));
  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}