
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import '../controller/SData.dart';
import '../models/mqtt.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeViewModel extends FullLifeCycleController with FullLifeCycleMixin{
  ApiServices api = ApiServices();
  late SharedPreferences sharedPreferences;
  String? id;
  String? passwd;
  String? nickname;
  String? pictureUrl;
  RxString userName = ''.obs;
  String msg = '';
  bool error = false;
  List<int> appkey = [];
  var encrypter;
  var encrypted;
  var decrypted;
  String door = '-2';
  late List<int> rdata;
  bool isScanning = false;
  String place = '';
  String stateText = 'Connecting';
  bool isSend = false;
  bool isAuth = false;
  bool isCom = false;
  RxString event = ''.obs;
  RxInt event2 = 0.obs;
  bool trigger = false;
  //도어쪽
  bool isBle = true;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  var scanResultList = [];
  List<BluetoothService> bluetoothService = [];

  Map<String, List<int>> notifyDatas = {};

  // 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
  StreamSubscription<BluetoothDeviceState>? stateListener;
// 현재 연결 상태 저장용
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
  late List<BluetoothService> services;
  var subscription;

  String doorRequest = '';


  Mqtt mqtt = new Mqtt();

  allupdate(){
   update();
  }

  void info() {
    chk();
    api.getInfo().then((value)  async {
      if (value['result'] == false) {
        // Get.snackbar(
        //   '알림',
        //   value['message']
        //   ,
        //   duration: const Duration(seconds: 5),
        //   backgroundColor: const Color.fromARGB(
        //       255, 39, 161, 220),
        //   icon: const Icon(Icons.info_outline, color: Colors.white),
        //   forwardAnimationCurve: Curves.easeOutBack,
        //   colorText: Colors.white,
        // );
        print(value['message']);
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
        sharedPreferences.setString('pcode', value['pcode']);
        sharedPreferences.setString('scode', value['scode']);
        sharedPreferences.setString('address', value['ble']['address']);
        place = value['personObj']['place'];
        update();
        print(place);

        String? pcode =  sharedPreferences.getString('pcode');
        String? scode =  sharedPreferences.getString('scode');
        print(pcode);
        print(scode);
        api.sendFcmToken('/GoogleFcmToken/saveAll').then((value)  async {
          print(value);
          if (value['result'] == true) {
            print('fcm토큰 전송 성공');
          }else{
            print('fcm토큰 전송 실패');
          }
        });

        if( user.product_sncode_id.toString() == '0'){
          print('등록 실패 홈');
          update();

        }else if(user.product_sncode_id.toString() != '0'){

          print('등록 성공 홈');
          update();
          String? scode =  sharedPreferences.getString('scode');
          String topic = 'smartdoor/SMARTDOOR/${scode}'; // Not a wildcard topic

          //client?.subscribe(topic, MqttQos.exactlyOnce);
          // var builder = MqttClientPayloadBuilder();
          // builder.addString('{"request":"isDoorOpen","topic":"smartdoor/SMARTDOOR/${sncode}/${familyid}/${personid}"}');
          // client?.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
        }
        // push();
      }
    }

    );
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


  setBleConnectionState(BluetoothDeviceState event) {
    switch (event) {
      case BluetoothDeviceState.disconnected:
        stateText = 'Disconnected';
        // 버튼 상태 변경
        update();
        break;
      case BluetoothDeviceState.disconnecting:
        stateText = 'Disconnecting';
        update();
        break;
      case BluetoothDeviceState.connected:
        stateText = 'Connected';
        update();
        // 버튼 상태 변경
        break;
      case BluetoothDeviceState.connecting:
        stateText = 'Connecting';
        update();
        break;
    }
    //이전 상태 이벤트 저장
    deviceState = event;
    update();
  }

  scan() async {
    doorRequest = '';
    print('scan 변수 ${doorRequest}');
    update();
    print(await flutterBlue.isOn);
    // Get.dialog(
    //     barrierDismissible: false,
    //     WillPopScope(
    //       onWillPop: () async => false,
    //       child: Center(
    //         child:
    //         Container(
    //             child:
    //             Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children:
    //               [
    //                 Material(
    //                   type: MaterialType.transparency,
    //                   child:
    //                   Obx(() =>  Text(
    //                     '작동중입니다. \n ${event}',
    //                     style: TextStyle(
    //                         color: Colors.white,
    //                         fontSize: 15
    //                     ),
    //                   ))
    //                   ,),
    //                 Container(height: 10,),
    //                 CircularProgressIndicator()
    //                 //   ,TextButton(onPressed: (){Get.back();}, child: Text('뒤로가기',
    //                 //   style: TextStyle(
    //                 //       color: Colors.white,
    //                 //       fontSize: 15
    //                 //   ),
    //                 // ))
    //               ],))
    //         ,),
    //     )
    // );
    await checkBluetoothOn().then((value){
      print(value);
      if(value == true){
        if (!isScanning) {
          // 스캔 중이 아니라면
          // 기존에 스캔된 리스트 삭제
          scanResultList.clear();
          // 스캔 시작, 제한 시간 4초
          flutterBlue.startScan(timeout: Duration(seconds: 20));
          // 스캔 결과 리스너

          flutterBlue.scanResults.listen((results) {
            results.forEach((element) async {
              //찾는 장치명인지 확인
              if (element.advertisementData.serviceUuids.length >= 2) {
                if (element.advertisementData.serviceUuids[1] == "48400001-b5a3-f393-e0a9-e50e24dcca9e"
                ) {
                  // 장치의 ID를 비교해 이미 등록된 장치인지 확인
                  if (scanResultList
                      .indexWhere((e) => e.device.id == element.device.id) <
                      0) {
                    // 찾는 장치명이고 scanResultList에 등록된적이 없는 장치라면 리스트에 추가
                    scanResultList.add(element);
                    print('찾음');
                    flutterBlue.stopScan();
                    print('scanResultList: ${scanResultList[0]}');
                    await flutterBlue.connectedDevices.whenComplete(() {
                      for (int i = 0; i < scanResultList.length; i++) {
                        scanResultList[i].device.disconnect();
                      }
                    });
                    stateListener = await scanResultList[0].device.state.listen((event) {
                      debugPrint('event :  $event');
                      print('$event 블루투스상태');
                      if (deviceState == event) {
                        // 상태가 동일하다면 무시
                        return;
                      }
                      // 연결 상태 정보 변경
                      setBleConnectionState(event);
                    });
                    if (deviceState == BluetoothDeviceState.disconnected) {
                      Future<bool>? returnValue;
                      scanResultList[0].device.connect(autoConnect: false)
                          .timeout(Duration(milliseconds: 15000), onTimeout: () {
                        //타임아웃 발생
                        //returnValue를 false로 설정
                        returnValue = Future.value(false);
                        print('타임아웃');
                        publish();
                        //연결 상태 disconnected로 변경
                        deviceState = BluetoothDeviceState.disconnected;
                        update();
                        setBleConnectionState(BluetoothDeviceState.disconnected);
                      }).then((data) async {

                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        if (returnValue == null) {
                          services = await scanResultList[0].device.discoverServices();
                          print('서비스 ${services}');
                          bluetoothService = services;
                          print('Service UUID: ${services[2].uuid}');
                          print('Service UUID: ${services[2].characteristics[0]}');
                          print('Service UUID: ${services[2].characteristics[0].uuid}');
                          print('Service UUID: ${services[2].characteristics[1].uuid}');
                          print('Service descriptors: ${services[2].characteristics[1].descriptors}');
                          isCom = false;
                          print(services[2].characteristics[1].deviceId);
                          print('주소 값 : ${sharedPreferences.getString('address')}');
                          if(!services[2].characteristics[1].isNotifying) {
                            try {
                              await services[2].characteristics[1].setNotifyValue(true);
                              if(isSend == false){
                                send(services[2], 0x48, 0x10);
                              }
                              subscription = services[2].characteristics[1].value.listen((value) {
                                // 데이터 읽기 처리!
                                if (services[2].characteristics[1].uuid.toString() ==
                                    '48400003-b5a3-f393-e0a9-e50e24dcca9e'
                                && sharedPreferences.getString('address') ==
                                    services[2].characteristics[1].deviceId.toString()
                                ) {
                                  print('같음');

                                  print('${services[2].characteristics[1].uuid}: 리턴값 $value');
                                  // 받은 데이터 저장 화면 표시용
                                  if (value.length != 0) {
                                    if (
                                    value[2] == 144
                                    ) {
                                      event.value = '키교환 완료';
                                      update();
                                      appkey =
                                      [value[3], value[4], value[5], value[6], value[7], value[8], value[9], value[10]];
                                      print('appkey 값 : ${appkey}');
                                      auth(services[2], 0x48, 0x11);


                                    } else {
                                      List<int> com = AESdecode(value);
                                      print('인증 디코딩');

                                      if (com[3] == 0 && com[2] == 0x91 && isAuth == true) {
                                        print('문열기 전송');
                                        event.value = '인증완료';
                                        update();
                                        test(services[2], 0x48, 0x21);
                                      }
                                      else if (com[3] == 1 && com[2] == 0x91 && isAuth == true) {
                                        event.value = '블루투스 인증 실패';
                                        print('인증실패');
                                        isSend = false;
                                        isAuth = false;
                                        isCom = true;
                                        print(isCom);
                                        update();
                                        subscription?.cancel();
                                        publish();
                                      }
                                      if (com[3] == 1 && com[2] == 0xA1) {
                                        Get.back();
                                        print('문열림');
                                        Get.dialog(QuitWidget(serverMsg: '닫기는 지원하지않습니다.'));
                                        isSend = false;
                                        isAuth = false;
                                        isCom = true;
                                        subscription?.cancel();
                                      } else if (com[3] == 0 && com[2] == 0xA1) {
                                        Get.back();
                                        Get.dialog(QuitWidget(serverMsg: '문이 열렸습니다.'));
                                        isSend = false;
                                        isAuth = false;
                                        isCom = true;
                                        subscription?.cancel();
                                      }

                                      // else {
                                      //   print('문열기실패');
                                      //   update();
                                      //   publish();
                                      // }
                                    }
                                  }
                                  // else{
                                  //   event.value = '블루투스 값 받기 실패';
                                  //   update();
                                  //   // subscription?.cancel();
                                  //   publish();
                                  // }
                                }
                              });
                              await Future.delayed(const Duration(milliseconds: 500));
                            } catch (e){
                              print('에러발생 $e');
                              subscription?.cancel();
                              publish();
                            }
                          }
                        }
                      }
                      )
                      ;
                      return returnValue ?? Future.value(false);
                    } else {
                      print(deviceState);
                      scanResultList[0].device.disconnect();
                      deviceState = BluetoothDeviceState.disconnected;
                      print('이미 연결됨');
                      publish();
                    }
                  }
                }
              }

            });
          })
          ;

        } else {
          // 스캔 중이라면 스캔 정지
          flutterBlue.stopScan();
          // Get.back();
          // Get.dialog(QuitWidget(serverMsg: '스캔중이거나 블루투스가 연결되어있지않습니다. \n 확인 후 다시 시도해주세요.'));

          publish();
        }
      }else{
        // Get.dialog(QuitWidget(serverMsg: '블루투스설정을 활성화 해주세요.',));
        print('블루투스꺼져있음 mqtt진입');
        trigger = false;
        door = '-3';
        event.value = '';
        update();
        publish();
      }
    }
    );
  }

  test(service,int STX,int cmd ) async{
    event.value = '문작동중';
    update();
    var now = new DateTime.now();
    List<int> Date = [
      0xff & (now.year >> 8),
      0xff & now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second
    ];
    for (int i in Date) {
      print('${i} 날짜값');
    }
    late List<int> Data;
    late List<int> open ;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? scode =  sharedPreferences.getString('scode');
    List<String>? spl = scode?.split('-');
    var fst = int.parse(spl![0]);
    assert(fst is int);
    var scd = int.parse(spl![1]);
    assert(scd is int);
    print(fst);
    print(scd);
    print(fst+scd);
    int sum2 =fst+scd;
    List<String> split = sum2.toString().split('');
    if(appkey != null){
       Data = [
        for(int i in Date)
          i,
        // for(String i in split)
        //   int.parse(i),
         71,72,73,74,75,76,77,78,
        0,0,7
      ];
      var obj = SData(cmd,Data);
      int Length = 1 + Data.length;
      int sum = 0;
      for (int i = 0; i < Data.length; i++) {
        sum += Data[i];
      }
      int ADD = (Length + cmd + sum)&0xff;
      print(ADD);
      print(obj.calcuChecksum(cmd, Data));
      print('비교');
      open = [STX, Data.length+1, cmd,
        for(int i in Data)
          i
        ,obj.calcuChecksum(cmd, Data)+1];
    }
    print(open);
    print(base64.encode(open));

    rdata = encrypt(open);

    var characteristics = service.characteristics;
    if(characteristics[0].uuid.toString() =='48400002-b5a3-f393-e0a9-e50e24dcca9e') {
      await characteristics[0].write(
          rdata
          , withoutResponse: true);
    }
    print('문열기문 전송');
    // for (BluetoothCharacteristic c in characteristics) {
    //   print(c.uuid);
    //   if (c.uuid.toString() == '48400002-b5a3-f393-e0a9-e50e24dcca9e') {
    //     await c.write(
    //         rdata
    //         , withoutResponse: true);
    //     print('암호화 된 문 전송');
    //     print('${rdata} 보낸거');
    //   }
    // }
  }

  send(service,int STX,int cmd) async {
    event.value = '키교환 전송중';
    update();
    List<int> send;
    var now = new DateTime.now();
    List<int> Date = [
      0xff & (now.year >> 8),
      0xff & now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second
    ];
    for (int i in Date) {
      print('${i} 날짜값');
    }

    List<int> Data //종류에따라 값이 다름
    =
    [
      for(int i in Date)
        i,
      61,62,63,64,65,66,67,68
    ];
    int Length = 1 + Data.length;

    // var obj = SData(cmd,Data);
    // print(obj.calcuChecksum(cmd, Data));

    int sum = 0; //data값 합계

    for (int i = 0; i < Data.length; i++) {
      sum += Data[i];
    }

    int ADD = (Length + cmd + sum)&0xff;
    print(ADD);
    print('비교' );
    send = [STX, Length, cmd,
      for(int i in Data)
        i,
      ADD];
    print('총 데이터 : ${send}');
    print(service);
    print(service.characteristics[0]);
    var characteristics = service.characteristics;
    if(characteristics[0].uuid.toString() =='48400002-b5a3-f393-e0a9-e50e24dcca9e') {
      await characteristics[0].write(
          send
          , withoutResponse: true);
    }

    print('키교환 전송');
    isSend = true;
    // for (BluetoothCharacteristic c in characteristics) {
    //   print(c.uuid);
    //   if (c.uuid.toString() == '48400002-b5a3-f393-e0a9-e50e24dcca9e') {
    //     await c.write(
    //         send
    //         , withoutResponse: true);
    //     print('암호화 안된 문 전송');
    //     print(Data);
    //     print('${send} 보낸거');
    //     update();
    //
    //   }
    // }
    return true;

  }
  auth(service,int STX,int Cmd) async{
    event.value = '인증중';
    print('인증문 전송');
    List<int> send;
    var now = new DateTime.now();
    List<int> Date = [
      0xff & (now.year >> 8),
      0xff & now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second
    ];
    for (int i in Date) {
      print('${i} 날짜값');
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? scode =  sharedPreferences.getString('scode');
    // List<String>? spl = scode?.split('-');
    // var fst = int.parse(spl![0]);
    // assert(fst is int);
    // var scd = int.parse(spl![1]);
    // assert(scd is int);
    // print(fst);
    // print(scd);
    // print(fst+scd);
    // int sum2 =fst+scd;
    // List<String> split = sum2.toString().split('');
    List<int> Data //종류에따라 값이 다름
    =
    [
      for(int i in Date)
        i,
      // for(String i in split)
      //   int.parse(i),
      71,72,73,74,75,76,77,78
    ];
    int Length = 1 + Data.length;

    var obj = SData(Cmd,Data);
    print(obj.calcuChecksum(Cmd, Data));

    int sum = 0; //data값 합계

    for (int i = 0; i < Data.length; i++) {
      sum += Data[i];
    }

    int ADD = (Length + Cmd + sum)&0xff;
    print(ADD);
    print('비교');
    send = [STX, Length, Cmd,
      for(int i in Data)
        i,
      //ADD
      obj.calcuChecksum(Cmd, Data)+1
    ];
    print('총 데이터 : ${send}');

    final rdata = encrypt(send);
    var characteristics = service.characteristics;
    if(characteristics[0].uuid.toString() =='48400002-b5a3-f393-e0a9-e50e24dcca9e') {
      await characteristics[0].write(
          rdata
          , withoutResponse: true);
    }
    isAuth = true;

    // for (BluetoothCharacteristic c in characteristics) {
    //   print(c.uuid);
    //   if (c.uuid.toString() == '48400002-b5a3-f393-e0a9-e50e24dcca9e') {
    //     await c.write(
    //         rdata
    //         , withoutResponse: true);
    //     print(Data);
    //     print('${rdata} 보낸거');
    //     update();
    //   }
    // }
  }
  encrypt(input){
    var k = paddingRight(input, 0);
    print('${k} 이걸 암호화');
    var iv = en.IV.fromBase64(
        base64.encode([61, 62, 63, 64, 65, 66, 67, 68,
          // 71, 72, 73, 74, 75, 76, 77, 78
          for(int i in appkey)
            i,
        ])
    );
    encrypter = en.Encrypter(en.AES(en.Key.fromUtf8('H-GANG BLE MODE1'), mode: en.AESMode.cbc, padding: null));
    encrypted = encrypter.encryptBytes(k, iv:  iv);
    print('${encrypted.bytes} 암호화');

    // var decrypted = encrypter.decryptBytes(en.Encrypted(Uint8List.fromList(encrypted.bytes)),
    //     iv: iv);
    // print(encrypted.bytes.length);
    // print('${decrypted} 바로 복호화');
    return encrypted.bytes;
  }
  paddingRight(List<int> data, value){
    int pcount = 16 - data.length % 16;
    print(data.length);
    print(pcount);
    for(var i = 0; i < pcount; i++){
      data.add(value);
    }
    print(data);
    print(Uint8List.fromList(data));
    return data;
  }

  AESdecode(val2) {
    print('받은 값 : ${val2}');
    print(base64.encode(val2));
    var iv = en.IV.fromBase64(
        base64.encode(
            [61, 62, 63, 64, 65, 66, 67, 68,
              //71, 72, 73, 74, 75, 76, 77, 78
              for(int i in appkey)
                i,
            ]
        )
    );
    print(Uint8List.fromList(val2));
    final encrypted = en.Encrypted(Uint8List.fromList(val2));
    // final encrypted = en.Encrypted(val2);
    var encrypter2 = en.Encrypter(en.AES(en.Key.fromUtf8('H-GANG BLE MODE1'), mode: en.AESMode.cbc, padding: null));
    decrypted = encrypter2.decryptBytes(encrypted, iv: iv);
    print('${decrypted} 디코딩완료');
    return decrypted;
  }

  publish(){
      if(mqtt.client?.connectionStatus?.state == MqttConnectionState.disconnected){
        mqtt.connect();
        print('커넥실패');
      }

      api.doorControl('/ProductSncode/doorlockAppOpenProcess').then((val){
        if (val['result'] == false) {
          Get.dialog(QuitWidget(serverMsg: val['message'],));
        }else{
          print('mqtt로 문열기');
          var i = 0;
            print('시작');
            Timer.periodic(Duration(seconds: 1), (timer) {
              print(i);
              print(trigger);
              if(trigger == true){
                print('mqtt 연결 성공ㅐ');
                trigger= false;
                timer.cancel();
                refresh();
              }else if (trigger == false && i == 15){
                print('mqtt 연결 실패ㅐ');
                Get.back();
                Get.dialog(QuitWidget(serverMsg: '시간이 초과되었습니다 다시 시도해주세요.',));
                timer.cancel();
                refresh();
              }
              i++;
            });
        }
      }
      );

  }

  push(){
    if(mqtt.client?.connectionStatus?.state == MqttConnectionState.disconnected){
      print('커넥실패');
      // connect();
    }
      String? pcode = sharedPreferences.getString('pcode');
      String? scode =  sharedPreferences.getString('scode');
      String? familyid =  sharedPreferences.getString('family_id');
      String? personid =  sharedPreferences.getString('person_id');
      print(pcode);
      print(scode);
      print(familyid);
      print(personid);
      var pubTopic = 'smartdoor/SMARTDOOR/${scode}';
      var builder = MqttClientPayloadBuilder();

      builder.addString('{"request":"productSncodeFamilyJoined","topic":"smartdoor/SMARTDOOR/${scode}","method":"input"}');
    mqtt.client?.subscribe(pubTopic, MqttQos.exactlyOnce);
    mqtt.client?.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);


      final connMessage =
      MqttConnectMessage().startClean().withWillQos(MqttQos.exactlyOnce);
      print(connMessage);
    mqtt.client!.published!.listen((MqttPublishMessage message) {
        print('EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
        print(message);

      });

  }
  updatedoor(val){
    if(val == 'true'){
      door = '1';
      print(door);
      print('도어값 변경 : 열림');
      update();
    }else if(val == 'false'){
      door = '0';
      print(door);
      print('도어값 변경 : 닫힘');
      update();
    }
  }


  void initBle() async {
    // BLE 스캔 상태 얻기 위한 리스너
    flutterBlue.scanResults.listen((event) {
      print(event);
    });
    flutterBlue.isScanning.listen((value) {
      isScanning = value;
      print('${isScanning} : 블루투스 상태');
      update();
    });


  }
  Future<bool> checkBluetoothOn() async {
    return await flutterBlue.isOn;
  }

  requestDoorRead(){

    // event2.value = 0;
    // trigger = false;
    doorRequest = '';
    Mqtt mqtt = new Mqtt();
    mqtt.connect();
    api.requestDoorRead('/ProductSncode/getDataByJson').then((val){
      print('문여부값');
      print(val['isDoorOpen']);
      print(val);
      // if (val['isDoorOpen'] == 1) {
      //   sharedPreferences.setString('door', '1');
      //   door = '1';
      //   update();
      // }else if (val['isDoorOpen'] == 0){
      //   sharedPreferences.setString('door', '0');
      //   door = '0';
      //   update();
      // }else{
      //   door = '-1';
      //   update();
      // }
      if(val['isDoorOpen'] == -1){
        door = '-1';
        update();
        // Get.dialog(
        //     barrierDismissible: false,
        //     WillPopScope(
        //       onWillPop: () async => false ,
        //       child: Center(
        //         child:
        //         Container(
        //             child:
        //             Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children:
        //               [
        //                 Material(
        //                   type: MaterialType.transparency,
        //                   child:
        //                   Obx(() =>  Text(
        //                     '문상태 조회중입니다.. \n ${event2.toString()}/15초',
        //                     style: TextStyle(
        //                         color: Colors.white,
        //                         fontSize: 15
        //                     ),
        //                   ))
        //                   ,),
        //                 Container(height: 10,),
        //                 CircularProgressIndicator()
        //                 //   ,TextButton(onPressed: (){Get.back();}, child: Text('뒤로가기',
        //                 //   style: TextStyle(
        //                 //       color: Colors.white,
        //                 //       fontSize: 15
        //                 //   ),
        //                 // ))
        //               ],))
        //         ,),
        //     )
        // );

        print('시작');
        Timer.periodic(Duration(seconds: 1), (timer) {
          print(event2.value);
          print(trigger);
          if(trigger == true){
            event2.value = 0;
            trigger= false;
            print('mqtt 연결 성공ㅐ');
            Get.back();
            timer.cancel();
          }else if (trigger == false && event2.value == 15){
            print('mqtt 연결 실패ㅐ');
            event2.value = 0;
            door = '-2';
            print(door);
            update();
            Get.back();
            Get.dialog(
                barrierDismissible: false,
                AlertDialog(
                  // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  //Dialog Main Title
                  title: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Text("알림")],
                    ),
                  ),
                  //
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '스마트도어에 연결할 수 없습니다.\n 다시 연결 시도할까요?',
                      )
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("확인"),
                      onPressed: () {
                        Get.back();
                        requestDoorRead();
                      },
                    ),
                    TextButton(
                      child: const Text("취소"),
                      onPressed: () {
                        Get.back();
                        door = '-2';
                        update();
                      },
                    ),
                  ],
                )
            );
            timer.cancel();
          }
          event2.value++;
        });
      }else
        if (val['isDoorOpen'] == 1) {
          door = '1';
          update();
        }else if (val['isDoorOpen'] == 0){
          door = '0';
          update();
         }else{
          door = '-2';
          Get.dialog(QuitWidget(
            serverMsg: '서버에서 에러가 발생했습니다. \n 앱을 다시 실행해주세요.',
          ));
          update();
        }

    });
  }

  @override
  void onInit(){
    info();
    requestDoorRead();
    initBle();
    print('메인 진입');
    super.onInit();
  }

  @override
  void onResumed() {
    print('onResumed');
    // Get.back();
    info();
    initBle();
    requestDoorRead();
  }

  @override
  void onClose() {

    //mqtt.client?.disconnect();
    // flutterBlue.turnOff();
    // scanResultList[0].device.disconnect();
    update();
    print('메인종료');
    super.onClose();

  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }
}