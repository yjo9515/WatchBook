
import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view_model/home_view_model.dart';

import '../view/widgets/QuitWidget.dart';


class Mqtt extends GetxController{
  MqttServerClient? client;


  Future<MqttServerClient?> connect() async {

    Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
      return client?.updates;
    }

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
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? personId = sharedPreferences.getString('person_id');
    List<int> nums = [];

    for( int i = 0; i < 9; i ++) {
      nums.add(Random().nextInt(9));
    }
    print(nums[0].toString()+nums[1].toString()+
        nums[2].toString()+nums[3].toString()+nums[4].toString()+nums[5].toString()+nums[6].toString()+
        nums[7].toString()+nums[8].toString());
    client =
        MqttServerClient.withPort('118.67.142.61', ' smartdoor_SMARTDOOR_${nums[0].toString()+nums[1].toString()+
            nums[2].toString()+nums[3].toString()+nums[4].toString()+nums[5].toString()+nums[6].toString()+
            nums[7].toString()+nums[8].toString()
        }', 1883);
    client?.logging(on: true);
    client?.autoReconnect = true;

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
      // Get.snackbar(
      //   '알림',
      //   '도어와 연결에 실패했습니다. '
      //   ,
      //   duration: const Duration(seconds: 5),
      //   backgroundColor: const Color.fromARGB(
      //       255, 39, 161, 220),
      //   icon: const Icon(Icons.info_outline, color: Colors.white),
      //   forwardAnimationCurve: Curves.easeOutBack,
      //   colorText: Colors.white,
      // );
      print('Exception: $e');
      client?.disconnect();
    }
    String? pcode = sharedPreferences.getString('pcode');
    String? sncode =  sharedPreferences.getString('scode');
    String? familyid =  sharedPreferences.getString('family_id');
    String? personid =  sharedPreferences.getString('person_id');

    String topic = 'smartdoor/SMARTDOOR/${sncode}/${familyid}/${personid}'; // Not a wildcard topic
    String topic2 = 'smartdoor/SMARTDOOR/${sncode}/${familyid}'; // Not a wildcard topic
    print(topic);
    print(topic2);
    print('토픽');
    client?.subscribe(topic, MqttQos.atLeastOnce);
    client?.subscribe(topic2, MqttQos.atLeastOnce);

    var home = Get.put(HomeViewModel());
    ;
  // var i = 0;
  // while(true){
  //   if(i > 10) break;
  //   i++;
  //   print(i);
    client?.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      home.trigger = true;
      print('리슨받음');
      update();
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
      MqttPublishPayload.bytesToStringAsString(message.payload.message);
      var result=json.decode(payload);
      print(result);
      print(Uri.decodeComponent(result['result'].toString()));
      if (Uri.decodeComponent(result['result'].toString()) == 'true' && Uri.decodeComponent(result['request'].toString()) == 'doorOpenProcess'){
        Get.back();
        home.updatedoor('true');
        Get.dialog(QuitWidget(serverMsg: '문이 열렸습니다.'));
        sharedPreferences.setString('door', 'true');
        refresh();
      }else if(Uri.decodeComponent(result['result'].toString()) == 'false'&& Uri.decodeComponent(result['request'].toString()) == 'doorOpenProcess') {
        Get.back();
        Get.dialog(QuitWidget(serverMsg: '자동문닫기 기능설정으로 문닫기를 실행할 수 없습니다.'));
      }
      else if(Uri.decodeComponent(result['result'].toString()) == 'true'&& Uri.decodeComponent(result['request'].toString()) == 'isDoorOpen') {
        home.updatedoor('true');
      }
      else if(Uri.decodeComponent(result['result'].toString()) == 'false'&& Uri.decodeComponent(result['request'].toString()) == 'isDoorOpen') {
        home.updatedoor('false');
      }
      print('qos설정값 : ${message.header!.qos}');
      getMessagesStream();
    });

  }
}
