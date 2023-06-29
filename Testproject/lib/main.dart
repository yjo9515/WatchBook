import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
      Phoenix(
        child:GetMaterialApp(
          debugShowCheckedModeBanner: false,
          home: home_view(),
        ) ,
      )
      );
}
class home_view extends GetView<HomeViewModel> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return GetBuilder<HomeViewModel>(
      init: HomeViewModel(),
      builder: (HomeViewModel) => WillPopScope(
          onWillPop: () => _goBack(context),
          child:  Scaffold(
              resizeToAvoidBottomInset: false,
              body:
              SafeArea(
                  child:
                  Container(
                      width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                      height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 20,
                      child: Stack(
                        children: [
                          Positioned(
                              top: 0,
                              child: Container(
                                width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                                height: 388,
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 87, 132, 255),
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(40), bottomLeft: Radius.circular(40))),
                                padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Text(HomeViewModel.place,
                                    //     style: TextStyle(
                                    //       fontSize: 20,
                                    //       color: Color.fromARGB(255, 255, 255, 255),
                                    //     )),
                                    Container(
                                      height: 20,
                                    ),
                                    TextButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(120.0),
                                          )),
                                        ),
                                        onPressed: () {
                                          if(HomeViewModel.door == '-3'){
                                            print('조회중일때 터치');
                                          }else{
                                            HomeViewModel.scan();
                                          }
                                          // HomeViewModel.publish();

                                        },
                                        child: Container(
                                          width: 220,
                                          height: 220,
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(255, 44, 95, 233),
                                              borderRadius: BorderRadius.all(Radius.circular(120))),
                                          child: Container(
                                            child: Container(
                                              child: HomeViewModel.door== '1' ? Icon(Icons.lock_open,
                                                  size: 40, color: Color.fromARGB(255, 255, 255, 255)):
                                              HomeViewModel.door== '0' ?
                                              Icon(Icons.lock,
                                                  size: 40, color: Color.fromARGB(255, 87, 132, 255)):
                                              HomeViewModel.door== '-1' ?
                                              Icon(Icons.search,
                                                  size: 40, color: Color.fromARGB(255, 87, 132, 255)):
                                              HomeViewModel.door== '-3' ?
                                              Icon(Icons.search,
                                                  size: 40, color: Color.fromARGB(255, 87, 132, 255))
                                                  :Icon(Icons.cancel,
                                                  size: 40, color: Color.fromARGB(255, 87, 132, 255))
                                              ,
                                              margin: EdgeInsets.fromLTRB(25, 25, 25, 25),
                                              width: 120,
                                              height: 120,
                                              decoration:HomeViewModel.door == '1' ? BoxDecoration(
                                                  color: Color.fromARGB(255, 14, 39, 158),
                                                  borderRadius: BorderRadius.all(Radius.circular(100))):
                                              HomeViewModel.door == '2' ?
                                              BoxDecoration(
                                                  color: Color.fromARGB(255, 255, 255, 255),
                                                  borderRadius: BorderRadius.all(Radius.circular(100)))
                                                  :
                                              BoxDecoration(
                                                  color: Color.fromARGB(255, 255, 255, 255),
                                                  borderRadius: BorderRadius.all(Radius.circular(100)))
                                              ,
                                            ),
                                            margin: EdgeInsets.fromLTRB(25, 25, 25, 25),
                                            width: 170,
                                            height: 170,
                                            decoration: BoxDecoration(
                                                color: Color.fromARGB(255, 87, 132, 255),
                                                borderRadius: BorderRadius.all(Radius.circular(100))),
                                          ),
                                        )),
                                    Container(
                                      height: 20,
                                    ),
                                    HomeViewModel.door == '1'?
                                    Text('도어가 열려있습니다.',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color.fromARGB(255, 255, 255, 255),
                                        )):HomeViewModel.door == '0'?
                                    Text('도어가 닫혀있습니다.',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color.fromARGB(255, 255, 255, 255),
                                        )):HomeViewModel.door == '-1'?Text('문상태 조회중입니다.',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color.fromARGB(255, 255, 255, 255),
                                        ))
                                        :HomeViewModel.door == '-3'?
                                    Text('문작동중',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color.fromARGB(255, 255, 255, 255),
                                        ))
                                        :Text('문상태 조회에 실패했습니다.',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color.fromARGB(255, 255, 255, 255),
                                        )),
                                  ],
                                ),
                              )),
                          Positioned(
                              top: 364,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.resolveWith(
                                              (states) {
                                            if (states.contains(MaterialState.disabled)) {
                                              return Colors.grey;
                                            } else {
                                              return Colors.white;
                                            }
                                          },
                                        ),
                                        shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(30)))),
                                      ),
                                      onPressed: () {
                                        //Get.to(() => camera_view());
                                      },
                                      child: Text('영상통화',
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Color.fromARGB(255, 87, 132, 255),
                                          )),
                                    ),
                                  ),
                                  Container(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.resolveWith(
                                              (states) {
                                            if (states.contains(MaterialState.disabled)) {
                                              return Colors.grey;
                                            } else {
                                              return Colors.white;
                                            }
                                          },
                                        ),
                                        shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(30)))),
                                      ),
                                      onPressed: () {
                                        //Get.to(entrance_view());
                                      },
                                      child: Text('출입이력',
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Color.fromARGB(255, 87, 132, 255),
                                          )),
                                    ),
                                  ),
                                  Container(
                                    height: 10,
                                  ),
                                  // SizedBox(
                                  //   width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                                  //   height: 50,
                                  //   child: ElevatedButton(
                                  //     style: ButtonStyle(
                                  //       backgroundColor: MaterialStateProperty.resolveWith(
                                  //             (states) {
                                  //           if (states.contains(MaterialState.disabled)) {
                                  //             return Colors.grey;
                                  //           } else {
                                  //             return Colors.white;
                                  //           }
                                  //         },
                                  //       ),
                                  //       shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.all(Radius.circular(30)))),
                                  //     ),
                                  //     onPressed: () {
                                  //       Get.to(member_view());
                                  //     },
                                  //     child: Text('구성원',
                                  //         style: TextStyle(
                                  //           fontSize: 17,
                                  //           color: Color.fromARGB(255, 87, 132, 255),
                                  //         )),
                                  //   ),
                                  // )
                                ],
                              ))
                        ],
                      ))

              ),

              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color.fromARGB(255, 87, 132, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
                actions: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      children: [
                        //     (home.nickname != null)?
                        // Text('${home.nickname} 님',
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     color: Color.fromARGB(255, 255, 255, 255),
                        //   ),
                        // ):Text('회원님',
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     color: Color.fromARGB(255, 255, 255, 255),
                        //   ),
                        // ),
                        IconButton(
                          onPressed: () {
                            //Get.to(() => cameraAuth_view());
                          },
                          icon: Icon(Icons.camera_alt, size: 19, color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        IconButton(
                          onPressed: () {
                            //Get.to(() => profile_view());
                          },
                          icon: Icon(Icons.account_circle, size: 19, color: Color.fromARGB(255, 255, 255, 255)),
                        )
                      ],
                    ),
                  )
                ],
              ),


          )),
    );
  }
  Future<bool> _goBack(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱을 종료하시겠어요?'),
        actions: <Widget>[
          TextButton(
            child: const Text('네'),
            onPressed: () => Navigator.pop(context, true),
          ),
          TextButton(
            child: const Text('아니오'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}

class HomeViewModel extends GetxController {
  bool isScanning = false;
  String stateText = 'Connecting';
  String door = '-2';
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  var scanResultList = [];
  List<BluetoothService> bluetoothService = [];
  // 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
  StreamSubscription<BluetoothDeviceState>? stateListener;
// 현재 연결 상태 저장용
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
  late List<BluetoothService> services;
  var subscription;
  bool isSend = false;
  bool isAuth = false;
  bool isCom = false;
  List<int> appkey = [];

  Future<bool> checkBluetoothOn() async {
    return await flutterBlue.isOn;
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

    update();
    print(await flutterBlue.isOn);
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
                                        update();
                                        test(services[2], 0x48, 0x21);
                                      }
                                      else if (com[3] == 1 && com[2] == 0x91 && isAuth == true) {
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

  publish(){
    // if(mqtt.client?.connectionStatus?.state == MqttConnectionState.disconnected){
    //   mqtt.connect();
    //   print('커넥실패');
    // }
    //
    // api.doorControl('/ProductSncode/doorlockAppOpenProcess').then((val){
    //   if (val['result'] == false) {
    //     Get.dialog(QuitWidget(serverMsg: val['message'],));
    //   }else{
    //     print('mqtt로 문열기');
    //     var i = 0;
    //     print('시작');
    //     Timer.periodic(Duration(seconds: 1), (timer) {
    //       print(i);
    //       print(trigger);
    //       if(trigger == true){
    //         print('mqtt 연결 성공ㅐ');
    //         trigger= false;
    //         timer.cancel();
    //         refresh();
    //       }else if (trigger == false && i == 15){
    //         print('mqtt 연결 실패ㅐ');
    //         Get.back();
    //         door = '-2';
    //         Get.dialog(QuitWidget(serverMsg: '시간이 초과되었습니다 다시 시도해주세요.',));
    //         timer.cancel();
    //         refresh();
    //       }
    //       i++;
    //     });
    //   }
    // }
    // );
    Get.dialog(QuitWidget(serverMsg: 'mqtt',));
  }
}
class QuitWidget extends StatelessWidget {
  final String serverMsg;
  QuitWidget({
    required this.serverMsg,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            serverMsg,
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("확인"),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    );
  }
}
