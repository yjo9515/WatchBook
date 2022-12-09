import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as en;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:byte_util/byte_util.dart';
import 'package:convert/convert.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:crypto/crypto.dart';



class Util {
  static List<int>? convertInt2Bytes(value, Endian order, int bytesSize ) {
    try{
      final kMaxBytes = 8;
      var bytes = Uint8List(kMaxBytes)
        ..buffer.asByteData().setInt64(0, value, order);
      List<int> intArray;
      if(order == Endian.big){
        intArray = bytes.sublist(kMaxBytes-bytesSize, kMaxBytes).toList();
      }else{
        intArray = bytes.sublist(0, bytesSize).toList();
      }
      return intArray;
    }catch(e) {
      print('util convert error: $e');
    }
    return null;
  }
}
class DeviceController extends GetxController {
   BluetoothDevice device = Get.arguments;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
// 연결 상태 표시 문자열
  String stateText = 'Connecting';

  // 연결 버튼 문자열
  String connectButtonText = 'Disconnect';

  // 현재 연결 상태 저장용
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  // 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
  StreamSubscription<BluetoothDeviceState>? stateListener;

  // 연결된 장치의 서비스 정보를 저장하기 위한 변수
  List<BluetoothService> bluetoothService = [];

  Map<String, List<int>> notifyDatas = {};

  var encrypter;
  var encrypted;

  var decrypted;

  // iv값 설정
  List<int> iv2 = [61, 62, 63, 64, 65, 66, 67, 68];
  List<int> ini = [0,0,0,0,0,0,0,0];

  List<int> iniData = [];
  late List<int> ivKey = [];
  late en.IV iv;

  //받을 수
  late bool isNeedDate;
  late bool isfirstRes;
  late bool isEncodeRes;
  var key;
  @override
  onInit() {
    super.onInit();
    stateListener = device.state.listen((event) {
      debugPrint('event :  $event');
      if (deviceState == event) {
        // 상태가 동일하다면 무시
        return;
      }
      // 연결 상태 정보 변경
      setBleConnectionState(event);
    });
    // 연결 시작
    connect();
  }

  @override
  onClose() {
    // 상태 리스터 해제
    stateListener?.cancel();
    // 연결 해제
    device.disconnect();
    print('연결 해제');
    super.onClose();
  }

  /* 연결 상태 갱신 */
  setBleConnectionState(BluetoothDeviceState event) {
    switch (event) {
      case BluetoothDeviceState.disconnected:
        stateText = 'Disconnected';
        // 버튼 상태 변경
        connectButtonText = 'Connect';
        break;
      case BluetoothDeviceState.disconnecting:
        stateText = 'Disconnecting';
        break;
      case BluetoothDeviceState.connected:
        stateText = 'Connected';
        // 버튼 상태 변경
        connectButtonText = 'Disconnect';
        break;
      case BluetoothDeviceState.connecting:
        stateText = 'Connecting';
        break;
    }
    //이전 상태 이벤트 저장
    deviceState = event;
    if(Get.routing.current == "/device_view"){
      update();
    }
  }

  /* 연결 시작 */
  Future<bool> connect() async {
    Future<bool>? returnValue;

      /* 상태 표시를 Connecting으로 변경 */
      stateText = 'Connecting';
      update();

    /*
      타임아웃을 10초(10000ms)로 설정 및 autoconnect 해제
       참고로 autoconnect가 true되어있으면 연결이 지연되는 경우가 있음.
     */
    await device
        .connect(autoConnect: false)
        .timeout(Duration(milliseconds: 15000), onTimeout: () {
      //타임아웃 발생
      //returnValue를 false로 설정
      returnValue = Future.value(false);
      debugPrint('timeout failed');

      //연결 상태 disconnected로 변경
      setBleConnectionState(BluetoothDeviceState.disconnected);
    }).then((data) async {
      if (returnValue == null) {
        //returnValue가 null이면 timeout이 발생한 것이 아니므로 연결 성공
        debugPrint('connection successful');

        List<BluetoothService> bleServices =
            await device.discoverServices();
          bluetoothService = bleServices;
          update();
        // 각 속성을 디버그에 출력
        for (BluetoothService service in bleServices) {
          print('============================================');
          print('Service UUID: ${service.uuid}');
          for (BluetoothCharacteristic c in service.characteristics) {
            print('\tcharacteristic UUID: ${c.uuid.toString()}');
            print('\t\twrite: ${c.properties.write}');
            print('\t\tread: ${c.properties.read}');
            print('\t\tnotify: ${c.properties.notify}');
            print('\t\tisNotifying: ${c.isNotifying}');
            print(
                '\t\twriteWithoutResponse: ${c.properties.writeWithoutResponse}');
            print('\t\tindicate: ${c.properties.indicate}');

            // notify나 indicate가 true면 디바이스에서 데이터를 보낼 수 있는 캐릭터리스틱이니 활성화 한다.
            // 단, descriptors가 비었다면 notify를 할 수 없으므로 패스!
            if (c.properties.notify && c.descriptors.isNotEmpty) {
              // 진짜 0x2902 가 있는지 단순 체크용!
              for (BluetoothDescriptor d in c.descriptors) {
                print('BluetoothDescriptor uuid ${d.uuid}');
                if (d.uuid == BluetoothDescriptor.cccd) {
                  print('d.lastValue: ${d.lastValue}');
                }
              }

              if (!c.isNotifying) {
                try {
                  await c.setNotifyValue(true);
                  // 받을 데이터 변수 Map 형식으로 키 생성
                  notifyDatas[c.uuid.toString()] = List.empty();
                  c.value.listen((value)  {
                    // 데이터 읽기 처리!
                    print('${c.uuid}: $value');
                    // 받은 데이터 저장 화면 표시용
                    notifyDatas[c.uuid.toString()] = value;
                    if ((isfirstRes == false && isEncodeRes == false) == true) {
                      print('암호화 안함');
                      // 초기 데이터 저장
                      iniData = value;
                      ivKey = [
                        iniData[3],
                        iniData[4],
                        iniData[5],
                        iniData[6],
                        iniData[7],
                        iniData[8],
                        iniData[9],
                        iniData[10],
                        61, 62, 63, 64, 65, 66, 67, 68
                      ];
                      iv = en.IV.fromBase64(base64.encode(ivKey));
                      print('초기(합친) 키 값 : ${ivKey}');
                    } else if ((isfirstRes == true && isEncodeRes == true) == true) {
                      print(value);
                      print('암호화 함');
                      // print(base64.encode(value));
                      // print(hex.encode(value));

                      final encryptedText = en.Encrypted(Uint8List.fromList(value));
                      final ctr = pc.CTRStreamCipher(pc.AESFastEngine())
                        ..init(false, pc.ParametersWithIV(pc.KeyParameter(key.bytes), iv.bytes));
                      Uint8List decrypted = ctr.process(encryptedText.bytes);

                      print(Uint8List.fromList(value));
                      print('${decrypted} 왓냐');
                      // // print('${stringToBase64.decode(encoded)} 지지지');
                      // // print(de);
                      // print(utf8.decode(de));
                      // // print(String.fromCharCodes(de));
                      // // print(String.fromCharCodes(ctr.process(en.Encrypted.fromBase64(encoded).bytes)));
                      // // // final encrypter2 = en.Encrypter(en.AES(key,padding : 'PKCS7'));
                      // //
                      // final encrypted = en.Encrypted(base64.decode(encoded));
                      final encrypted2 = en.Encrypted.fromBase64(base64.encode(value));
                      final encrypter2 = en.Encrypter(en.AES(key, mode: en.AESMode.cbc,padding: null));
                      print(encrypted2.toString());
                      print(encrypter2.decrypt(encrypted2,iv: iv).runes.toList());

                      final encryptedBytes = encrypter.decrypt(
                        en.Encrypted(Uint8List.fromList(value)),
                        iv: iv,
                      ).runes.toList();
                      
                      print('${encryptedBytes} : 디코딩까지 끝');
                      // decrypted = encrypter2.decrypt(en.Encrypted.fromBase64(encoded), iv: iv);
                      // decrypted = encrypter2.decrypt(en.Encrypted(base64Decode(encode)), iv: iv);

                      String iv3 = '[${ivKey.join(', ')}]';

                    }
                  });
                    update();
                  // 설정 후 일정시간 지연
                  await Future.delayed(const Duration(milliseconds: 500));
                } catch (e) {
                  print('error ${c.uuid} $e');
                }
              }
            }
          }
        }
      returnValue = Future.value(true);
      }
    });

    return returnValue ?? Future.value(false);
  }

  Future<bool> connectWIFI() async {
    Future<bool>? returnValue;

    /* 상태 표시를 Connecting으로 변경 */
    stateText = 'Connecting';
    update();

    /*
      타임아웃을 10초(10000ms)로 설정 및 autoconnect 해제
       참고로 autoconnect가 true되어있으면 연결이 지연되는 경우가 있음.
     */
    await device
        .connect(autoConnect: false)
        .timeout(Duration(milliseconds: 15000), onTimeout: () {
      //타임아웃 발생
      //returnValue를 false로 설정
      returnValue = Future.value(false);
      debugPrint('timeout failed');

      //연결 상태 disconnected로 변경
      setBleConnectionState(BluetoothDeviceState.disconnected);
    }).then((data) async {
      if (returnValue == null) {
        //returnValue가 null이면 timeout이 발생한 것이 아니므로 연결 성공
        debugPrint('connection successful');

        List<BluetoothService> bleServices =
        await device.discoverServices();
        bluetoothService = bleServices;
        update();
        // 각 속성을 디버그에 출력
        for (BluetoothService service in bleServices) {
          print('============================================');
          print('Service UUID: ${service.uuid}');
          for (BluetoothCharacteristic c in service.characteristics) {
            print('\tcharacteristic UUID: ${c.uuid.toString()}');
            print('\t\twrite: ${c.properties.write}');
            print('\t\tread: ${c.properties.read}');
            print('\t\tnotify: ${c.properties.notify}');
            print('\t\tisNotifying: ${c.isNotifying}');
            print(
                '\t\twriteWithoutResponse: ${c.properties.writeWithoutResponse}');
            print('\t\tindicate: ${c.properties.indicate}');

            // notify나 indicate가 true면 디바이스에서 데이터를 보낼 수 있는 캐릭터리스틱이니 활성화 한다.
            // 단, descriptors가 비었다면 notify를 할 수 없으므로 패스!
            if (c.properties.notify && c.descriptors.isNotEmpty) {
              // 진짜 0x2902 가 있는지 단순 체크용!
              for (BluetoothDescriptor d in c.descriptors) {
                print('BluetoothDescriptor uuid ${d.uuid}');
                if (d.uuid == BluetoothDescriptor.cccd) {
                  print('d.lastValue: ${d.lastValue}');
                }
              }

              if (!c.isNotifying) {
                try {
                  await c.setNotifyValue(true);
                  // 받을 데이터 변수 Map 형식으로 키 생성
                  notifyDatas[c.uuid.toString()] = List.empty();
                  c.value.listen((value)  {
                    // 데이터 읽기 처리!
                    print('${c.uuid}: $value');
                    // 받은 데이터 저장 화면 표시용
                    notifyDatas[c.uuid.toString()] = value;
                    if ((isfirstRes == false && isEncodeRes == false) == true) {
                      print('암호화 안함');
                      // 초기 데이터 저장
                      iniData = value;
                      ivKey = [
                        iniData[3],
                        iniData[4],
                        iniData[5],
                        iniData[6],
                        iniData[7],
                        iniData[8],
                        iniData[9],
                        iniData[10],
                        61, 62, 63, 64, 65, 66, 67, 68
                      ];
                      iv = en.IV.fromBase64(base64.encode(ivKey));
                      print('초기(합친) 키 값 : ${ivKey}');
                    } else if ((isfirstRes == true && isEncodeRes == true) == true) {
                      print(value);
                      print('암호화 함');
                      // print(base64.encode(value));
                      // print(hex.encode(value));

                      final encryptedText = en.Encrypted(Uint8List.fromList(value));
                      final ctr = pc.CTRStreamCipher(pc.AESFastEngine())
                        ..init(false, pc.ParametersWithIV(pc.KeyParameter(key.bytes), iv.bytes));
                      Uint8List decrypted = ctr.process(encryptedText.bytes);

                      print(Uint8List.fromList(value));
                      print('${decrypted} 왓냐');
                      // // print('${stringToBase64.decode(encoded)} 지지지');
                      // // print(de);
                      // print(utf8.decode(de));
                      // // print(String.fromCharCodes(de));
                      // // print(String.fromCharCodes(ctr.process(en.Encrypted.fromBase64(encoded).bytes)));
                      // // // final encrypter2 = en.Encrypter(en.AES(key,padding : 'PKCS7'));
                      // //
                      // final encrypted = en.Encrypted(base64.decode(encoded));
                      final encrypted2 = en.Encrypted.fromBase64(base64.encode(value));
                      final encrypter2 = en.Encrypter(en.AES(key, mode: en.AESMode.cbc,padding: null));
                      print(encrypted2.toString());
                      print(encrypter2.decrypt(encrypted2,iv: iv).runes.toList());

                      final encryptedBytes = encrypter.decrypt(
                        en.Encrypted(Uint8List.fromList(value)),
                        iv: iv,
                      ).runes.toList();

                      print('${encryptedBytes} : 디코딩까지 끝');
                      // decrypted = encrypter2.decrypt(en.Encrypted.fromBase64(encoded), iv: iv);
                      // decrypted = encrypter2.decrypt(en.Encrypted(base64Decode(encode)), iv: iv);

                      String iv3 = '[${ivKey.join(', ')}]';

                    }
                  });
                  update();
                  // 설정 후 일정시간 지연
                  await Future.delayed(const Duration(milliseconds: 500));
                } catch (e) {
                  print('error ${c.uuid} $e');
                }
              }
            }
          }
        }
        returnValue = Future.value(true);
      }
    });

    return returnValue ?? Future.value(false);
  }


  /* 연결 해제 */
  void disconnect() {
    try {
        stateText = 'Disconnecting';
        device.disconnect();
        update();
    } catch (e) {}
  }

  void encode(String plainText, en.IV iv){
    // 초기 문자열
    print('초기문자열 ${plainText}');
    // 문자열을 byte로
    List<int> byteString = utf8.encode(plainText);;
    // print('Byte로 변환한 문자열 : ${byteString}');
    // byte값을 aes 128 cbc 방식으로 인코딩
    // AESEncode(byteString,iv);
    AESEncode(plainText,iv);
  }

  void decode(val){
    // 인코딩 된 값을 디코딩
    AESdecode(iv,val);
  }

  AESEncode(byteString,iv){
    // 키 값 설정
    key = en.Key.fromUtf8('H-GANG BLE MODE1');
    // 키 값 설정후 encrypt
    encrypter = en.Encrypter(en.AES(key, mode: en.AESMode.cbc));
    encrypted = encrypter.encrypt(byteString.toString(), iv: iv);
    print(byteString);
    print('AES로 인코딩 된 값 : ${base64.decode(encrypted.base64)}');
  }

  AESdecode(iv,val2){
    print('받은 값 : ${val2}');
     // decrypted = encrypter.decrypt64(base64.encode(val2), iv: iv);

  }

  //stx값,cmd값,데이터(날짜),데이터(앱키 처음실행여부),데이터(암호화 여부)
  send(service,int STX,int Cmd,bool needDate,bool isfirst,bool isEncode ) async{
    List<int> send;
    if(needDate) // 날짜 데이터가 필요할때
        {
      var now = new DateTime.now();
      int year = int.parse(DateFormat('yyyy').format(now));
      int month = int.parse(DateFormat('M').format(now));
      int day = int.parse(DateFormat('d').format(now));
      int hour = int.parse(DateFormat('h').format(now));
      int minute = int.parse(DateFormat('mm').format(now));
      int second = int.parse(DateFormat('ss').format(now));
      print(day);
      print(hour);
      print(minute);
      print(second);
      List<int> Date = [
        0xff & (year >> 8),
        0xff & year,
        0xff & month,
        0xff & day,
        0xff & hour,
        0xff & minute,
        0xff & second,
      ];
      for (int i in Date) {
        print('${i} 날짜값');
      }


      List<int> Data //종류에따라 값이 다름
      =
      [
          for(int i in Date)
            i,
          for(int iv in iv2)
            iv,
        // if(isfirst == true && isEncode == true)
        //   for(int iv in ivKey)
        //     iv,
        // if(isfirst == true && isEncode == false)
        // //데이트값
        // for(int i in Date)
        //   i,
        // // 암호화 key (초기엔 0)
        // if(isfirst == true && isEncode == false)
        //   for(int iv in ini)
        //     iv,
        //
        // if(isfirst == false && isEncode == false)
        // //데이트값
        //   for(int i in Date)
        //     i,
        // if(isfirst == false && isEncode == false)
        //   for(int i in ini)
        //     i,
      ];




      int Length = 1 + Data.length;

      int sum = 0; //data값 합계

      for (int i = 0; i < Data.length; i++) {
        sum += Data[i];
      }

      int ADD = Length + Cmd + sum;

      send = [STX, Length, Cmd,
        for(int i in Data)
          i,
        ADD];
      print('총 데이터 : ${send}');



      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        print(c.uuid);
        if (c.uuid.toString() == '48400002-b5a3-f393-e0a9-e50e24dcca9e') {
          if(isEncode == true){
            encode(send.toString(), iv);
            // encode('H-GANG SECURITY This text has 44 characters.', iv);
            // aes로 인코딩딩
            Uint8List byteList = Uint8List.fromList(ivKey);
            print('${byteList} dddddd');
            print(base64.decode(encrypted.base64));
            print(hex.encode(base64.decode(encrypted.base64)));
            c.write(
                base64.decode(encrypted.base64)
                , withoutResponse: true);
            print('암호화 된 문 전송');
            isfirstRes = isfirst;
            isEncodeRes = isEncode;
            isNeedDate = needDate;

            print(isfirst);
            print(isEncode);
            print(Data);
            print('${send} 암호화샌드');

          }else{
            c.write(
                send
                , withoutResponse: true);
            print('암호화 안된 문 전송');
            isfirstRes = isfirst;
            isEncodeRes = isEncode;
            isNeedDate = needDate;
            print(isfirst);
            print(isfirstRes);
            print(isEncode);
            print(isEncodeRes);
            print(Data);
            print('${send} 보낸거');
          }

      }
    }}
  }


  Widget buildService(BluetoothService service) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            send(service, 0x48, 0x10 , true, false, false);
          },
          icon: const Icon(Icons.send_to_mobile_sharp, size: 20),
          label: const Text("전송(Send)"),
        ),
        TextButton(onPressed: (){send(service, 0x48, 0x11,true ,true, true);}, child: Text('등록요청')),

      ],
    );
  }


  List<Widget> buildServiceTiles(List<BluetoothService> services) {
    return services.map((s) {
      return buildService(s);
    }).toList();
  }

  Widget buildServices() {
    return StreamBuilder<List<BluetoothService>>(
      stream: device.services,
      initialData: [],
      builder: (c, snapshot) {
        return Column(
          children: buildServiceTiles(snapshot.data!),
        );
      },
    );
  }

  Widget buildIconButton() {
    return StreamBuilder<BluetoothDeviceState>(
        stream: device.state,
        initialData: BluetoothDeviceState.connecting,
        builder: (c, snapshot) {
          if (snapshot.data != BluetoothDeviceState.connected)
            return Icon(Icons.warning);
          return IconButton(
              icon: Icon(Icons.bluetooth_searching),
              onPressed: () => device.discoverServices());
        });
  }

  /* 각 캐릭터리스틱 정보 표시 위젯 */
  Widget characteristicInfo(BluetoothService r) {
    String name = '';
    String properties = '';
    String data = '';
    // 캐릭터리스틱을 한개씩 꺼내서 표시
    for (BluetoothCharacteristic c in r.characteristics) {
      properties = '';
      data = '';
      name += '\t\t${c.uuid}\n';
      if (c.properties.write) {
        properties += 'Write ';
      }
      if (c.properties.read) {
        properties += 'Read ';
      }
      if (c.properties.notify) {
        properties += 'Notify ';
        if (notifyDatas.containsKey(c.uuid.toString())) {
          // notify 데이터가 존재한다면
          if (notifyDatas[c.uuid.toString()]!.isNotEmpty) {
            data = notifyDatas[c.uuid.toString()].toString();
          }
        }
      }
      if (c.properties.writeWithoutResponse) {
        properties += 'WriteWR ';
      }
      if (c.properties.indicate) {
        properties += 'Indicate ';
      }
      name += '\t\t\tProperties: $properties\n';
      if (data.isNotEmpty) {
        // 받은 데이터 화면에 출력!
        name += '\t\t\t\t$data\n';
      }
    }
    return Text(name);
  }

  /* Service UUID 위젯  */
  Widget serviceUUID(BluetoothService r) {
    String name = '';
    name = r.uuid.toString();
    return Text(name);
  }

  /* Service 정보 아이템 위젯 */
  Widget listItem(BluetoothService r) {
    return ListTile(
      onTap: null,
      title: serviceUUID(r),
      subtitle: characteristicInfo(r),
    );
  }

}
