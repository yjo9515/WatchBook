import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:wisemonster/controller/ble_controller.dart';

import 'device_view.dart';

class ble_view extends GetView<BleController>{
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetBuilder<BleController>(
        init: BleController(),
        builder: (BleController) => WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
              width:
              MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
              height:
              MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .height,
              color: Colors.white,
              child:Center(
                /* 장치 리스트 출력 */
                child: ListView.separated(
                  itemCount: BleController.scanResultList.length,
                  itemBuilder: (context, index) {
                    return listItem(BleController.scanResultList[index]);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
              )
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: BleController.scan,
            // 스캔 중이라면 stop 아이콘을, 정지상태라면 search 아이콘으로 표시
            child: Icon(BleController.isScanning ? Icons.stop : Icons.search),
          ),
        )
    ));
  }

  Widget listItem(ScanResult r) {
    return ListTile(
      onTap: () => onTap(r),
      leading: leading(r),
      title: deviceName(r),
      subtitle: deviceMacAddress(r),
      trailing: deviceSignal(r),
    );
  }





  /*
   여기서부터는 장치별 출력용 함수들
  */
  /*  장치의 신호값 위젯  */
  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }

  /* 장치의 MAC 주소 위젯  */
  Widget deviceMacAddress(ScanResult r) {
    return Text(r.device.id.id);
  }

  /* 장치의 명 위젯  */
  Widget deviceName(ScanResult r) {
    String name = '';

    // if (r.device.name.isNotEmpty) {
    //   // device.name에 값이 있다면
    //   name = r.device.name;
    // } else
      if (r.advertisementData.localName.isNotEmpty) {
      // advertisementData.localName에 값이 있다면
      if (r.advertisementData.serviceUuids[1] == '48400001-b5a3-f393-e0a9-e50e24dcca9e'){
        name = 'Solity Door Lock';
      }
      // name = r.advertisementData.localName;
    } else {
      // 둘다 없다면 이름 알 수 없음...
      name = '알 수 없음';
    }
    return Text(name);
  }

  /* BLE 아이콘 위젯 */
  Widget leading(ScanResult r) {
    return CircleAvatar(
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
      backgroundColor: Colors.cyan,
    );
  }

  /* 장치 아이템을 탭 했을때 호출 되는 함수 */
  void onTap(ScanResult r) {
    print('${r.advertisementData.serviceUuids[1]}');
    Get.to(() => device_view(),arguments: r.device);
  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }

}