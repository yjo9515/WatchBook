import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';

import '../controller/camera_controller.dart';

class camera_view extends GetView<CameraController> {

  camera_view({Key? key}) : super(key: key);


  // Build UI
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraController>(
      init:CameraController(),
      builder:(CameraController)=>
      MaterialApp(

      home:
      Obx(()=>
          Scaffold(
          appBar: AppBar(
            title: const Text('Get started with Video Calling'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              // Container for the local video
              Container(
                height: 240,
                decoration: BoxDecoration(border: Border.all()),
                child: Center(child: CameraController.localPreview()),
              ),
              const SizedBox(height: 10),
              //Container for the Remote video
              Container(
                height: 240,
                decoration: BoxDecoration(border: Border.all()),
                child: Center(child: CameraController.remoteVideo()),
              ),
              // Button Row
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: CameraController.isJoined.value ? null : () => {CameraController.join()},
                      child: const Text("Join"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: CameraController.isJoined.value ? () => {CameraController.leave()} : null,
                      child: const Text("Leave"),
                    ),
                  ),
                ],
              ),
              // Button Row ends
            ],
          ))

      ),
    ));
  }



}
