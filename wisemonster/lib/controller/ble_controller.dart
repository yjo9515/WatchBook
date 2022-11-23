import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleController extends GetxController {

  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<ScanResult> scanResultList = [];
  bool isScanning = false;



  @override
  onInit() {
    super.onInit();
    initBle();
    print('블루투스 진입점');
  }

  @override
  onClose() {
    flutterBlue.turnOff();
    print('블루투스 다운');
    super.onClose();
  }

  void initBle() {
    // BLE 스캔 상태 얻기 위한 리스너
    flutterBlue.isScanning.listen((value) {
      isScanning = value;
      print('${isScanning} : 블루투스 상태');
      update();
    });
  }

  /*
  스캔 시작/정지 함수
  */
  scan() async {
    if (!isScanning) {
      // 스캔 중이 아니라면
      // 기존에 스캔된 리스트 삭제
      scanResultList.clear();
      // 스캔 시작, 제한 시간 4초
      flutterBlue.startScan(timeout: Duration(seconds: 4));
      // 스캔 결과 리스너
      flutterBlue.scanResults.listen((results) {
        // List<ScanResult> 형태의 results 값을 scanResultList에 복사
        scanResultList = results;
        // UI 갱신
        update();
      });
    } else {
      // 스캔 중이라면 스캔 정지
      flutterBlue.stopScan();
    }
  }
}
