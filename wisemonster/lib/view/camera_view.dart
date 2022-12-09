
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../api/api_services.dart';
import '../controller/camera_controller.dart';
import '../view_model/home_view_model.dart';

class camera_view extends StatefulWidget {
  camera_view({Key? key}) : super(key: key);

  // Build UI


  @override
  State<StatefulWidget> createState() => cameraState();
}

class cameraState extends State<camera_view> {
  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home:

        Scaffold(
            body: ListView(
              children: [
                Container(
                  height: 76,
                  color: Color.fromARGB(255, 204, 204, 204),
                ),
                Container(
                  height:  (MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 152)/2,
                  decoration: BoxDecoration(border: Border.all()),
                  child: Center(child: localPreview()),
                ),
                Container(
                  height: (MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 152)/2,
                  decoration: BoxDecoration(border: Border.all()),
                  child: Center(child: remoteVideo()),
                ),
                // Container for the local video
                //Container for the Remote video
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
                        onPressed: isJoined ? (){} : () => {join()},
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
                        onPressed: isJoined ? () => {leave()} : null,
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
                        onPressed: (){control();},
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

        ,
      );
  }


  ApiServices api = ApiServices();
  bool door = true;


  String appId = "554d4edeb650484c92fd9a6e48ff67bf";
  String channelName = "wisemonster";
  String token = "";
  String token2 = "007eJxTYAhYWyU5fcNxxv2HjdK/6k34u1ZWMbva+2zUHE1PxWUarxkUGExNTVJMUlNSk8xMDUwsTJItjdJSLBPNUk0s0tLMzJPSmtdPTG4IZGR4yzORgREKQXxuhvLM4tTc/LziktQiBgYAC9UiNA==";

  int uid = 1; // uid of the local user

  int? remoteUid; // uid of the remote user
  bool isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance


  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey
  = GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

// Display local video preview
  Widget localPreview() {
    if (isJoined == true) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: uid),
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
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      String msg = '';
      if (isJoined) msg = '유저연결을 기다리는 중 입니다.';
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

    print(token);
    print(channelName);
    print(uid);

    await agoraEngine.joinChannel(
      token: token2,
      channelId: channelName,
      options: options,
      uid: uid,
    );
  }

  void leave() {
    setState(() {
      isJoined = false;
      remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  showMessage(String message) {
    Get.snackbar(
      '알림',
      // '다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.'
      message
      ,
      duration: Duration(seconds: 5),
      backgroundColor: const Color.fromARGB(
          255, 39, 161, 220),
      icon: Icon(Icons.info_outline, color: Colors.white),
      forwardAnimationCurve: Curves.easeOutBack,
      colorText: Colors.white,
    );
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();
    // Get.snackbar(
    //   '알림',
    //   // '다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.'
    //   token2
    //   ,
    //   duration: Duration(seconds: 5),
    //   backgroundColor: const Color.fromARGB(
    //       255, 39, 161, 220),
    //   icon: Icon(Icons.info_outline, color: Colors.white),
    //   forwardAnimationCurve: Curves.easeOutBack,
    //   colorText: Colors.white,
    // );
    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
      appId: '554d4edeb650484c92fd9a6e48ff67bf',
    ));

    // await agoraEngine.setClientRole( role: ClientRoleType.clientRoleBroadcaster);
    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage("Local user uid:${connection.localUid} joined the channel");
          print('조인완료');
          setState(() {
            isJoined = true;
          });

        },
        onUserJoined: (RtcConnection connection, int _remoteUid, int elapsed) {
          showMessage("Remote user uid:$_remoteUid joined the channel");
          setState(() {
            remoteUid = _remoteUid;
          });

        },
        onUserOffline: (RtcConnection connection, int _remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$_remoteUid left the channel");
          setState(() {
            remoteUid = null;
          });

        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );
  }

  control(){
    var home = Get.put(HomeViewModel());
    if(door){
      home.publish(door);

    }else{
      home.publish(door);
    }

  }

  @override
  void initState() {
    super.initState();
    api.requestRTCToken('/ProductSncode/getAgoraToken').then((value) {
      // if (value['result'] == false) {
      //   Get.snackbar(
      //     '알림',
      //     value['message']
      //     ,
      //     duration: Duration(seconds: 5),
      //     backgroundColor: const Color.fromARGB(
      //         255, 39, 161, 220),
      //     icon: Icon(Icons.info_outline, color: Colors.white),
      //     forwardAnimationCurve: Curves.easeOutBack,
      //     colorText: Colors.white,
      //   );
      // }else{
      if(value != null){
        print(value);
        setState(() {
          token = value.trim();
        });


      }
    });
    setupVideoSDKEngine();
    print('엔진');
  }
  @override
  void dispose() async{
    // destroy sdk
    print('엔진 끄기');
    super.dispose();
       // agoraEngine.leaveChannel();
    await agoraEngine.leaveChannel(options: LeaveChannelOptions(stopAllEffect: true));
  }
}
