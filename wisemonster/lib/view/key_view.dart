import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view/addkey_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import '../controller/member_controller.dart';
import 'widgets/LeftSlideWidget.dart';

class key_view extends GetView<MemberController> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
        centerTitle: true,
        title: Text('게스트 키', style: TextStyle(
            color: Color.fromARGB(255, 44, 95, 233),
            fontWeight: FontWeight.bold,
            fontSize: 20)),
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
      body: Container(
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
                                flex: 36,
                                  child: Container(
                                width: 106,
                                height:50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(onPressed: (){},
                                        icon:Icon(Icons.info_outline,
                                            size: 32, color: Color.fromARGB(255, 44, 95, 233))
                                    ),
                                    IconButton(onPressed: (){},
                                        icon:Image.asset(
                                          'images/icon/pencil.png',
                                          fit: BoxFit.contain,
                                          alignment: Alignment.center,
                                        )
                                    ),
                                    IconButton(onPressed: (){},
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
      drawer: LeftSlideWidget(),
    );
  }
}
