import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view/addMember_view.dart';
import '../controller/member_controller.dart';
import 'home_view.dart';

class member_view extends GetView<MemberController>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
        centerTitle: true,
        title: Text('구성원', style: TextStyle(
            color: Color.fromARGB(255, 44, 95, 233),
            fontWeight: FontWeight.bold,
            fontSize: 20)),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Get.offAll(home_view());
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.to(addMember_view());
              },
              child: Text(
                '초대',
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
            Expanded(
                child:ListView.builder(
                    itemBuilder: (BuildContext context, int index){
                      return Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                            borderRadius: BorderRadius.all(Radius.circular(12))),
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        height: 80,
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
                                flex: 35,
                                child:Text(
                                  '구성원',
                                  style: TextStyle(
                                    fontSize: 14,

                                  ),
                                )
                            )
                            ,
                            Expanded(
                                flex: 20,
                                child: Container(
                                  width: 56,
                                  height:50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(onPressed: (){
                                        // Get.to(() => );
                                      },
                                          icon:Image.asset(
                                            'images/icon/pencil.png',
                                            fit: BoxFit.contain,
                                            alignment: Alignment.center,
                                          )
                                      ),
                                      IconButton(onPressed: (){

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
    );
  }

}