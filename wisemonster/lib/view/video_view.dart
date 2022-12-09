import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:wisemonster/view/addkey_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/VideoWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import '../controller/entrance_controller.dart';
import '../controller/member_controller.dart';
import '../controller/video_controller.dart';
import 'widgets/LeftSlideWidget.dart';

class video_view extends GetView<VideoController> {


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: GetBuilder<VideoController>(
            init: VideoController(),
            builder: (VideoController) => Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
                    centerTitle: true,
                    title: Text('녹화기록',
                        style: TextStyle(
                            color: Color.fromARGB(255, 44, 95, 233), fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  body: Container(
                    margin: EdgeInsets.fromLTRB(16, 40, 16, 0),
                    width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                    height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height,
                    child: GroupedListView<dynamic, String>(
                      elements: VideoController.elements,
                      groupBy: (element) => element['group'],
                      groupComparator: (value1, value2) => value2.compareTo(value1),
                      itemComparator: (item1, item2) => item1['name'].compareTo(item2['name']),
                      order: GroupedListOrder.DESC,
                      useStickyGroupSeparators: true,
                      groupSeparatorBuilder: (String value) => Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 87, 132, 255),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            value,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),

                      itemBuilder: (c, element) {
                        return Card(
                          elevation: 8.0,
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: SizedBox(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              leading: Text('${element['name']}'),
                              title: Text('${element['group']}'),
                              trailing: IconButton(onPressed: () {
                                if(element['filepath'] == null || element['filepath'] == ''){
                                Get.snackbar(
                                  '알림',
                                  'url값이 없습니다 관리자에게 문의해주세요.'

                                  ,
                                  duration: Duration(seconds: 5),
                                  backgroundColor: const Color.fromARGB(
                                      255, 39, 161, 220),
                                  icon: Icon(Icons.info_outline, color: Colors.white),
                                  forwardAnimationCurve: Curves.easeOutBack,
                                  colorText: Colors.white,
                                );}else{
                                  print(element['filepath']);
                                  Get.dialog(VideoWidget(url: element['filepath'],));
                                }

                              }, icon:Icon(Icons.play_arrow),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  drawer: LeftSlideWidget(),
                )));
  }

  Future<bool> _goBack(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱을 종료하시겠어요?'),
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
