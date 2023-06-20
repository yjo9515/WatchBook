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
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/login_view.dart';

import '../api/api_services.dart';
import '../models/user_model.dart';
import '../view/afterQr_view.dart';



class QRController extends GetxController {
  Barcode? result;
  QRViewController? qrcontroller;
  ApiServices api = ApiServices();
  // late SharedPreferences sharedPreferences;

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

  sendCode (Barcode? result) async {
      print(result?.code);
      api.get('/Smartdoor/findByCode?code=${result?.code}').then((value) async {
        if(value.statusCode == 200) {
          if(json.decode(value.body)['smartdoor_id'] == "" || json.decode(value.body)['smartdoor_id'] == null){
            print('다른거');
            Get.back();
            Get.snackbar(
              '알림',
              '다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.'
              ,
              duration: const Duration(seconds: 5),
              backgroundColor: const Color.fromARGB(
                  255, 39, 161, 220),
              icon: const Icon(Icons.info_outline, color: Colors.white),
              forwardAnimationCurve: Curves.easeOutBack,
              colorText: Colors.white,
            );
            qrcontroller!.dispose();
          }else{
            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
            print(sharedPreferences.getString('user_id'));
            api.post(json.encode({'smartdoor_id':json.decode(value.body)['smartdoor_id'],'user_id':sharedPreferences.getString('user_id')}),'/SmartdoorUser').then((value) async {
              // Get.to(afterQr_view(),arguments: [value['params']['pcode'],value['params']['sncode'],value['params']['product_sncode_id']]);
              if(value.statusCode == 200) {
                Get.offAll(home_view());
              }else if(value.statusCode == 401){
                Get.offAll(login_view());
                Get.snackbar(
                  '알림',
                  utf8.decode(value.reasonPhrase!.codeUnits)
                  ,
                  duration: Duration(seconds: 5),
                  backgroundColor: const Color.fromARGB(
                      255, 39, 161, 220),
                  icon: Icon(Icons.info_outline, color: Colors.white),
                  forwardAnimationCurve: Curves.easeOutBack,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  '알림',
                  utf8.decode(value.reasonPhrase!.codeUnits)
                  ,
                  duration: Duration(seconds: 5),
                  backgroundColor: const Color.fromARGB(
                      255, 39, 161, 220),
                  icon: Icon(Icons.info_outline, color: Colors.white),
                  forwardAnimationCurve: Curves.easeOutBack,
                  colorText: Colors.white,
                );
              }

            });
          }
        }else{
          Get.snackbar(
            '알림',
            utf8.decode(value.reasonPhrase!.codeUnits)
            ,
            duration: Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        }

      });
    // api.sendQRcode(result).then((value) async {
    //   print(value['result']);
    //   // if (value == 'another') {
    //   //   // msg = "인증에 실패하였습니다.\n창을 닫은 후 다시 촬영해주세요.";
    //   //   // msg = "다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.";
    //   //   error = true;
    //   //   // Get.dialog(QuitWidget(serverMsg: msg));
    //   //   Get.snackbar(
    //   //     '알림',
    //   //     '다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.'
    //   //     ,
    //   //     duration: Duration(seconds: 5),
    //   //     backgroundColor: const Color.fromARGB(
    //   //         255, 39, 161, 220),
    //   //     icon: Icon(Icons.info_outline, color: Colors.white),
    //   //     forwardAnimationCurve: Curves.easeOutBack,
    //   //     colorText: Colors.white,
    //   //   );
    //   //
    //   //   register = false;
    //   //   update();
    //   // } else
    //   if (value['result'] == false) {
    //     print('다른거');
    //     Get.back();
    //     Get.snackbar(
    //       '알림',
    //       // '다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.'
    //       value['message']
    //       ,
    //       duration: const Duration(seconds: 5),
    //       backgroundColor: const Color.fromARGB(
    //           255, 39, 161, 220),
    //       icon: const Icon(Icons.info_outline, color: Colors.white),
    //       forwardAnimationCurve: Curves.easeOutBack,
    //       colorText: Colors.white,
    //     );
    //     qrcontroller!.dispose();
    //
    //     update();
    //   } else if(value['result']  == true)  {
    //     // model(value);
    //     print('리턴값 : ${value}');
    //     print(value['params']['pcode']);
    //     print(value['params']['sncode']);
    //     print(value['params']['product_sncode_id']);
    //     sharedPreferences = await SharedPreferences.getInstance();
    //     sharedPreferences.setString('pcode', value['params']['pcode']);
    //     sharedPreferences.setString('scode', value['params']['sncode']);
    //     sharedPreferences.setString('product_sncode_id', value['params']['product_sncode_id'].toString());
    //     print(value);
    //     print('qr인증완료');
    //     qrcontroller!.dispose();
    //     // Get.offAll(home_view());
    //     Get.to(afterQr_view(),arguments: [value['params']['pcode'],value['params']['sncode'],value['params']['product_sncode_id']]);
    //     update();
    //   }
    //
    // });
    refresh();
  }

  void onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('권한이 없습니다.')),
      );
    }
  }
  @override
  onInit() {
    super.onInit();
  }

  @override
  onClose() {
    // 상태 리스터 해제
    qrcontroller?.dispose();
    super.onClose();

  }
}