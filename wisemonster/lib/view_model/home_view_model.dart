
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/src/types/barcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/models/user_model.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/widgets/QrWidget.dart';
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import '../view/login_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeViewModel extends GetxController{
  ApiServices api = ApiServices();
  late SharedPreferences sharedPreferences;
  String? id;
  String? passwd;
  String? nickname;
  String? pictureUrl;
  RxString userName = ''.obs;
  String msg = '';
  bool error = false;

  Barcode? result;
  QRViewController? qrcontroller;
  bool door = true;

  allupdate(){
   update();
  }

  void info() {
    chk();
    api.getInfo().then((value)  async {
      if (value['result'] == false) {
        Get.snackbar(
          '알림',
          value['message']
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
        update();
      } else {
        Map<String, dynamic> userMap = value;
        var user = UserModel.fromJson(userMap);
        userName.value = user.personObj['name'].toString();
        print('전달할 유저 이름 : ${userName}');
        sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('name', user.personObj['name'].toString());
        sharedPreferences.setString('person_id', user.personObj['person_id'].toString());
        sharedPreferences.setString('family_id', user.familyId.toString());
        sharedPreferences.setString('family_person_id', user.familyPersonId.toString());
        sharedPreferences.setString('nickname', user.personObj['nickname'].toString());
        sharedPreferences.setString('pictureUrl', user.personObj['pictureUrl'].toString());
        sharedPreferences.setString('product_sncode_id', user.product_sncode_id.toString());

        String? pcode =  sharedPreferences.getString('pcode');
        String? sncode =  sharedPreferences.getString('sncode');
        print(pcode);
        print(sncode);
        api.sendFcmToken('/GoogleFcmToken/saveAll').then((value)  async {
          print(value);
          if (value['result'] == true) {
            print('fcm토큰 전송 성공');
          }else{
            print('fcm토큰 전송 실패');
          }
        });

        if(pcode == null || sncode == null){
          qrcontroller?.dispose();
          print('등록 실패');
          update();
        }else if(pcode != null && sncode != null){
          qrcontroller?.dispose();
          print('등록 성공');
          update();

        }
        push();
      }
    }

    );
  }


  sendCode (Barcode? result) {
    api.sendQRcode(result).then((value) async {
      print(value['result']);
      // if (value == 'another') {
      //   // msg = "인증에 실패하였습니다.\n창을 닫은 후 다시 촬영해주세요.";
      //   // msg = "다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.";
      //   error = true;
      //   // Get.dialog(QuitWidget(serverMsg: msg));
      //   Get.snackbar(
      //     '알림',
      //     '다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.'
      //     ,
      //     duration: Duration(seconds: 5),
      //     backgroundColor: const Color.fromARGB(
      //         255, 39, 161, 220),
      //     icon: Icon(Icons.info_outline, color: Colors.white),
      //     forwardAnimationCurve: Curves.easeOutBack,
      //     colorText: Colors.white,
      //   );
      //
      //   register = false;
      //   update();
      // } else
        if (value['result'] == false) {
        print('다른거');
        Get.back();
        Get.snackbar(
          '알림',
          // '다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.'
          value['message']
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
        qrcontroller!.dispose();

        update();
      } else if(value['result']  == true)  {
        // model(value);
        print('리턴값 : ${value}');
        print(value['params']['pcode']);
        sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('pcode', value['params']['pcode']);
        sharedPreferences.setString('sncode', value['params']['sncode']);
        print(value);
        print('qr인증완료');
        qrcontroller!.dispose();
        Get.offAll(home_view());
        update();
      }

    });
    refresh();
  }

  void onQRViewCreated(QRViewController controller) {
    this.qrcontroller = controller;
    controller.scannedDataStream.listen((scanData) {
      if(scanData.code != null){
        this.qrcontroller?.pauseCamera();
        result = scanData;
        print(scanData.code);
        sendCode(result);
      }
    });
  }
  void onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('권한이 없습니다.')),
      );
    }
  }

  model(value) async {
    Map<String, dynamic> userMap = await jsonDecode(value);
    var user = UserModel.fromJson(userMap);
    print(user.personObj['name']);
    userName.value = user.personObj['name'].toString();
    update();
  }


  void initDialog(value) {
    Get.dialog(
        QuitWidget(serverMsg: msg)
    );
  }

  chk() async {
    sharedPreferences = await SharedPreferences.getInstance();
     id = sharedPreferences.getString('id');
     passwd = sharedPreferences.getString('passwd');
     nickname = sharedPreferences.getString('nickname');
      pictureUrl = sharedPreferences.getString('pictureUrl');
     print('chk');
  }

  final ImagePicker _picker = ImagePicker();
  File? image;
  Future getImage() async {
    final XFile? pickImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickImage != null){
      image = File(pickImage.path);
      final bytes = image?.readAsBytesSync();
      String base64Image =  "data:image/png;base64,"+base64Encode(bytes!);
      print(base64Image);
      update();
    }
  }

  MqttServerClient? client;

  Future<MqttServerClient?> connect() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? personId = sharedPreferences.getString('person_id');
    client =
        MqttServerClient.withPort('118.67.142.61', ' smartdoor_SMARTDOOR_2022${personId}', 1883);
    client?.logging(on: true);
    client?.onConnected = onConnected;
    client?.onDisconnected = onDisconnected;
    client?.onUnsubscribed = onUnsubscribed;
    client?.onSubscribed = onSubscribed;
    client?.onSubscribeFail = onSubscribeFail;
    client?.pongCallback = pong;




    final connMessage = MqttConnectMessage()
        .keepAliveFor(60)
        .withWillTopic('smartdoor/SMARTDOOR/')
        .withWillMessage('doorlockOpenProcess')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client?.connectionMessage = connMessage;
    try {
      Get.snackbar(
        '알림',
        '도어와 연결중입니다. 잠시만 기다려주세요.'
        ,
        duration: Duration(seconds: 5),
        backgroundColor: const Color.fromARGB(
            255, 39, 161, 220),
        icon: Icon(Icons.info_outline, color: Colors.white),
        forwardAnimationCurve: Curves.easeOutBack,
        colorText: Colors.white,
      );
      await client?.connect();
    } catch (e) {
      Get.snackbar(
        '알림',
        '연결에 실패했습니다. 어플을 다시 실행해주세요.'
        ,
        duration: Duration(seconds: 5),
        backgroundColor: const Color.fromARGB(
            255, 39, 161, 220),
        icon: Icon(Icons.info_outline, color: Colors.white),
        forwardAnimationCurve: Curves.easeOutBack,
        colorText: Colors.white,
      );
      print('Exception: $e');
      client?.disconnect();
    }
    String? pcode = sharedPreferences.getString('pcode');
    String? sncode =  sharedPreferences.getString('sncode');
    String? familyid =  sharedPreferences.getString('family_id');
    String? personid =  sharedPreferences.getString('person_id');

    String topic = 'smartdoor/SMARTDOOR/${sncode}/${familyid}/${personid}'; // Not a wildcard topic
    client?.subscribe(topic, MqttQos.atMostOnce);

    client?.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
      MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Received message:$payload from topic: ${c[0].topic}>');

      var result=json.decode(payload);
      print(result['message']);
      print(Uri.decodeComponent(result['message']));
      Get.snackbar(
        '알림',
        Uri.decodeComponent(result['message'])
        ,
        duration: Duration(seconds: 5),
        backgroundColor: const Color.fromARGB(
            255, 39, 161, 220),
        icon: Icon(Icons.info_outline, color: Colors.white),
        forwardAnimationCurve: Curves.easeOutBack,
        colorText: Colors.white,
      );
      getMessagesStream();
    });

    return client;
  }

  // connection succeeded
  void onConnected() {
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
  Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
    return client?.updates;
  }
  publish(door){
    if(client?.connectionStatus?.state == MqttConnectionState.disconnected){
      connect();
      print('커넥실패');
    }else{
      String? pcode = sharedPreferences.getString('pcode');
      String? sncode =  sharedPreferences.getString('sncode');
      String? familyid =  sharedPreferences.getString('family_id');
      String? personid =  sharedPreferences.getString('person_id');

      print(pcode);
      print(sncode);
      print(familyid);
      print(personid);
      var pubTopic = 'smartdoor/SMARTDOOR/${sncode}';
      var builder = MqttClientPayloadBuilder();
      if(door){
        builder.addString('{"request":"doorlockAppOpenProcess","topic":"smartdoor/SMARTDOOR/${sncode}/${familyid}/${personid}"}');
      }else{
        builder.addString('{"request":"doorlockAppCloseProcess"}');
      }


      client?.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!);


      final connMessage =
      MqttConnectMessage().startClean().withWillQos(MqttQos.atLeastOnce);
      print(connMessage);
      client!.published!.listen((MqttPublishMessage message) {
        print('EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
        print(message);

      });
    }
  }

  push(){
    if(client?.connectionStatus?.state == MqttConnectionState.disconnected){
      print('커넥실패');
      connect();
    }else{
      String? pcode = sharedPreferences.getString('pcode');
      String? sncode =  sharedPreferences.getString('sncode');
      String? familyid =  sharedPreferences.getString('family_id');
      String? personid =  sharedPreferences.getString('person_id');

      print(pcode);
      print(sncode);
      print(familyid);
      print(personid);
      var pubTopic = 'smartdoor/SMARTDOOR/${sncode}';
      var builder = MqttClientPayloadBuilder();

        builder.addString('{"request":"productSncodeFamilyJoined","topic":"smartdoor/SMARTDOOR/${sncode}","method":"output"}');



      client?.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!);


      final connMessage =
      MqttConnectMessage().startClean().withWillQos(MqttQos.atLeastOnce);
      print(connMessage);
      client!.published!.listen((MqttPublishMessage message) {
        print('EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
        print(message);

      });
    }
  }

  @override
  void onInit(){

    connect();
    info();
    print('메인 진입');
    super.onInit();
  }

  @override
  void onClose() {
    qrcontroller?.dispose();
    update();
    print('메인종료');
    super.onClose();
  }
}