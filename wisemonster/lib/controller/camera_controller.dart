

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisemonster/view/camera_view.dart';

import '../view_model/camera_view_model.dart';

class CameraController extends GetxController{
  String appId = "554d4edeb650484c92fd9a6e48ff67bf";
  String channelName = "wisemonster";
  String token = "007eJxTYLB0u7DkymcN9mdhc2wsRbcLL1IPTdk6Y01A7Jz/eYfDD79UYDA1NUkxSU1JTTIzNTCxMEm2NEpLsUw0SzWxSEszM09K05wSn9wQyMjwxPQEEyMDBIL43AzlmcWpufl5xSWpRQwMAGIQI10=";

  RxInt uid = 0.obs; // uid of the local user

  RxInt remoteUid = 0.obs; // uid of the remote user
  RxBool isJoined = false.obs; // Indicates if the local user has joined the channel
  RtcEngine agoraEngine = createAgoraRtcEngine(); // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey
  = GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

// Display local video preview
  Widget localPreview() {
    if (isJoined.isTrue) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: uid.value),
        ),
      );
    } else {
      return Text(
        '통화 버튼을 눌러 도어와 연결해주세요.',
        textAlign: TextAlign.center,
        style:TextStyle(
            color: Color.fromARGB(255, 44, 233, 94),
            fontSize: 20
        )
      );
    }
  }

// Display remote user's video
  Widget remoteVideo() {
    if (remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: remoteUid.value),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      String msg = '';
      if (isJoined.isTrue) msg = '유저연결을 기다리는 중 입니다.';
      return Text(
        msg,
        textAlign: TextAlign.center,
      );
    }
  }

  void join() async {
    await agoraEngine.startPreview();

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid.value,
    );
  }

  void leave() {
    isJoined.value = false;
    remoteUid.value = 0;

    agoraEngine.leaveChannel();
  }

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
        appId: '554d4edeb650484c92fd9a6e48ff67bf'
    ));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage("Local user uid:${connection.localUid} joined the channel");
          isJoined = true.obs;
        },
        onUserJoined: (RtcConnection connection, int remoteUid2, int elapsed) {
          showMessage("Remote user uid:$remoteUid2 joined the channel");
          remoteUid = remoteUid2.obs;
        },
        onUserOffline: (RtcConnection connection, int remoteUid3,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid3 left the channel");
          remoteUid = 0.obs;
        },
      ),
    );
  }
  @override
  void onInit() {
    setupVideoSDKEngine();
    super.onInit();
    print('엔진');

  }
  @override
  void onClose() async{
    // destroy sdk
    print('엔진 끄기');
    await agoraEngine.leaveChannel(options: LeaveChannelOptions(stopAllEffect: true));
    super.onClose();

  }

}