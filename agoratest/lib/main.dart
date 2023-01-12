import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
const String appId = "554d4edeb650484c92fd9a6e48ff67bf";

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String channelName = "test";
  String token = "007eJxTYPhdu8GhddW1FxW1gZ+lOeQWKKpOymb21L6e+jeOeVYcY40Cg6mpSYpJakpqkpmpgYmFSbKlUVqKZaJZqolFWpqZeVIaR+rM5IZARoYt12oYGRkgEMRnYShJLS5hYAAAAzEekA==";

  int uid = 0; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey
  = GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

// Build UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
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
                child: Center(child: _localPreview()),
              ),
              const SizedBox(height: 10),
              //Container for the Remote video
              Container(
                height: 240,
                decoration: BoxDecoration(border: Border.all()),
                child: Center(child: _remoteVideo()),
              ),
              // Button Row
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isJoined ? null : () => {join()},
                      child: const Text("Join"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isJoined ? () => {leave()} : null,
                      child: const Text("Leave"),
                    ),
                  ),
                ],
              ),
              TextButton(onPressed: (){publish(false);}, child: Text('버튼'))
              // Button Row ends
            ],
          )),
    );
  }

// Display local video preview
  Widget _localPreview() {
    if (_isJoined) {
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
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      String msg = '';
      if (_isJoined) msg = 'Waiting for a remote user to join';
      return Text(
        msg,
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Set up an instance of Agora engine
    connect();
    setupVideoSDKEngine();
  }

  MqttServerClient? client;
  publish(door){
    // if(client?.connectionStatus?.state == MqttConnectionState.disconnected){
    //   connect();
    //   print('커넥실패');
    // }
    var pubTopic = 'smartdoor/SMARTDOOR/20221121-10000003';
    
      var builder = MqttClientPayloadBuilder();
      builder.addString('{"request":"doorlockAppOpenProcess","topic":"smartdoor/SMARTDOOR/20221121-10000003"}');
      client?.publishMessage(pubTopic, MqttQos.atMostOnce, builder.payload!);
    client!.published!.listen((MqttPublishMessage message) {
      print('EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
      print('보낼때');
      print(message.payload);
    });

  }
  Future<MqttServerClient?> connect() async {


    client =
        MqttServerClient.withPort('118.67.142.61', ' smartdoor_SMARTDOOR_123456789'
        , 1883);
    client?.logging(on: true);
    client?.onConnected = onConnected;
    client?.onDisconnected = onDisconnected;
    client?.onUnsubscribed = onUnsubscribed;
    client?.onSubscribed = onSubscribed;
    client?.onSubscribeFail = onSubscribeFail;
    client?.pongCallback = pong;




    final connMessage = MqttConnectMessage()
    // .keepAliveFor(60)
    // .withWillTopic('smartdoor/SMARTDOOR/')
        .startClean()
        .withWillQos(MqttQos.exactlyOnce);
    client?.connectionMessage = connMessage;
    try {

      await client?.connect();
    } catch (e) {
      print('Exception: $e');
      client?.disconnect();
    }

    String topic = 'smartdoor/SMARTDOOR/20221121-10000003/11/19'; // Not a wildcard topic
    client?.subscribe(topic, MqttQos.atLeastOnce);

    client?.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
      MqttPublishPayload.bytesToStringAsString(message.payload.message);

      var result=json.decode(payload);
      print(result);
      print('qos설정값 : ${message.header!.qos}');
      getMessagesStream();
    });

    return client;
  }

  // connection succeeded
  void onConnected() {
    // Get.snackbar(
    //   '알림',
    //   '도어와 연결 되었습니다.'
    //   ,
    //   duration: const Duration(seconds: 5),
    //   backgroundColor: const Color.fromARGB(
    //       255, 39, 161, 220),
    //   icon: const Icon(Icons.info_outline, color: Colors.white),
    //   forwardAnimationCurve: Curves.easeOutBack,
    //   colorText: Colors.white,
    // );
    print('Connected');
    // String? pcode = sharedPreferences.getString('pcode');
    // String? sncode =  sharedPreferences.getString('sncode');
    // String? familyid =  sharedPreferences.getString('family_id');
    // String? personid =  sharedPreferences.getString('person_id');
    // String topic = 'smartdoor/SMARTDOOR/${sncode}'; // Not a wildcard topic
    //
    // //client?.subscribe(topic, MqttQos.exactlyOnce);
    // var builder = MqttClientPayloadBuilder();
    // builder.addString('{"request":"isDoorOpen","topic":"smartdoor/SMARTDOOR/${sncode}/${familyid}/${personid}"}');
    // client?.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

// unconnected
  void onDisconnected() {
    print('Disconnected');
  }

// subscribe to topic succeeded
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

// subscribe to topic failed
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

// unsubscribe succeeded
  void onUnsubscribed(String? topic) {
    print('Unsubscribed topic: $topic');
  }

// PING response received
  void pong() {
    print('Ping response client callback invoked');
  }
  Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
    return client?.updates;
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
        appId: appId
    ));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage("Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
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
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

// Clean up the resources when you leave
  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    super.dispose();
  }
}