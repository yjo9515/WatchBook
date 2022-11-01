import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';

import '../controller/camera_controller.dart';

class camera_view extends GetView<CameraController> {
  camera_view({Key? key}) : super(key: key);
  final camera = Get.put(CameraController());

  // Build UI
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraController>(
      init:CameraController(),
      builder:(CameraController)=>
      MaterialApp(
          debugShowCheckedModeBanner: false,
      home:
      Obx(()=>
          Scaffold(
          body: ListView(
            children: [
              Container(
                height: 76,
                color: Color.fromARGB(255, 204, 204, 204),
              ),
              // Container for the local video
              Container(
                height:  (MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 152)/2,
                decoration: BoxDecoration(border: Border.all()),
                child: Center(child: CameraController.localPreview()),
              ),
              //Container for the Remote video
              Container(
                height: (MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 152)/2,
                decoration: BoxDecoration(border: Border.all()),
                child: Center(child: CameraController.remoteVideo()),
              ),
              Container(
                height: 76,
                color: Color.fromARGB(255, 204, 204, 204),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        flex: 29,
                        child: Container()
                    ),
                    TextButton(
                      onPressed: CameraController.isJoined.value ? (){} : () => {CameraController.join()},
                      child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 44, 233, 94),
                          ),
                          child: Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 24,
                          )),),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: CameraController.isJoined.value ? () => {CameraController.leave()} : null,
                      child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 24,
                          )),),
                    TextButton(
                      onPressed: (){CameraController.leave();},
                      child: Container(
                          width: 84,
                          height: 36,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(255, 87, 132, 255)
                          ),
                          child: Center(child: Text(
                            '열기',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14
                            ),
                          ),) ),),
                    Expanded(
                        flex: 29,
                        child: Container()
                    ),
                  ],
                ),
              )
              // Button Row
              // Button Row ends
            ],
          ))

      ),
    ));
  }



}
