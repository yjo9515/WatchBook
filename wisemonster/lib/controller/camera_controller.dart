

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisemonster/view/camera_view.dart';

import '../view_model/camera_view_model.dart';

class CameraController extends GetxController{
  // CameraViewModel cam = CameraViewModel();
  String appId = "com.wikibox.wisemonster";
  String channelName = "<--Insert channel name here-->";
  String token = "<--Insert authentication token here-->";

  int uid = 0; // uid of the local user

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
          canvas: VideoCanvas(uid: uid),
        ),
      );
    } else {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
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
      if (isJoined.isTrue) msg = 'Waiting for a remote user to join';
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
      uid: uid,
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
        appId: 'com.wikibox.wisemonster'
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
          showMessage("Remote user uid:$remoteUid left the channel");
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
}