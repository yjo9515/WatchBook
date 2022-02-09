import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Member extends StatefulWidget {
  @override
  MemberState createState() => MemberState();
}

class MemberState extends State<Member> {
  WebViewController? _webViewController;
  final Completer<WebViewController> _controllerCompleter =
  Completer<WebViewController>();
  Iterable<Contact> _contact = [];
  List<Contact> result = [];
  List<String> phones = [];

  bool chk = false; // 약관동의 및 전화전호부 등록
  @override
  void initState() {
    super.initState();
    _checkContact().then((value) async => {
      if (value == false)
        {_getStatuses()}
      else {
        _contact = await ContactsService.getContacts(),
    _contact.forEach((contact) {
    contact.phones.toSet().forEach((phone) {
    phones.add(phone.value);
    });
    }),
        downloadList()
      }
    });
  }

  // 연락처권한요청
   _getStatuses() async {
    if(Platform.isAndroid){
      Map<Permission, PermissionStatus> statuses =
      await [Permission.contacts].request();
      if (await Permission.contacts.isGranted == true) {
        print('연락처 권한 동의');
        return Future.value(true);
      } else {
        print('연락처 권한 비동의');
        return Future.value(false);
      }
    }else{
      const snackBar =
      const SnackBar(content: Text('연락처 권한을 동의해 주세요.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      openAppSettings();
      Navigator.pop(context);
    }
  }

  _askPermissions() async {
    // PermissionStatus permissionStatus = await _getContactPermission();
    // if (permissionStatus == PermissionStatus.granted) {
    //   downloadList();
    // } else {
    //   _contact = await ContactsService.getContacts();
    //   result = _contact.toList();
    //   _handleInvalidPermissions(permissionStatus);
    // }
  }

  Future<bool> _checkContact() async {
    var status = await Permission.contacts.status;
    print('연락처 체크값 : ${status}');
    if (status.isGranted) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  // Future<PermissionStatus> _getContactPermission() async {
  //   PermissionStatus permission = await Permission.contacts.status;
  //   if (permission != PermissionStatus.granted &&
  //       permission != PermissionStatus.denied) {
  //     PermissionStatus permissionStatus = await Permission.contacts.request();
  //     return permissionStatus;
  //   } else {
  //     return permission;
  //   }
  // }
  //
  // void _handleInvalidPermissions(PermissionStatus permissionStatus) {
  //   if (permissionStatus == PermissionStatus.denied) {
  //     const snackBar = const SnackBar(content: Text('연락처 데이터에 대한 액세스가 거부되었습니다.'));
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     // openAppSettings();
  //     // Navigator.pop(context);
  //   }
  //   // else if (permissionStatus == PermissionStatus.permanentlyDenied) {
  //   //   const snackBar =
  //   //   const SnackBar(content: Text('단말기에서 연락처 데이터를 사용할 수 없습니다.'));
  //   //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   //   openAppSettings();
  //   //   Navigator.pop(context);
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: new AppBar(
       title: const Text('전화번호부'),
     ),
     body:
     chk == true
     ?
     WebView(
       key: UniqueKey(),
       initialUrl: 'https://m.watchbook.tv/friends/list',
       onWebViewCreated: (WebViewController webViewController) {
         _controllerCompleter.future
             .then((value) => _webViewController = value);
         _controllerCompleter.complete(webViewController);
       },
       javascriptMode: JavascriptMode.unrestricted,
     )
     : const Center(child: Text('불러오고 있어유'),),
   );
  }

  downloadList() async {
    try{

      result = _contact.toList();
      print(chk);
      List _contactMaps = result.map((e) => e.toMap()).toList();
      print(_contactMaps);
      print(result.length);
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String? tokenValue = sharedPreferences.getString('token');
      String rs = '';
      String avatar = '';

      // for(int i = 0; i < result.length; i++ ){
      //   // print('${i}');
      //   // print(result[i].displayName);
      //   // print(_contactMaps[i]['phones'][0]['value']);
      //   //print('cart[]=${i}&name[${i}]=${result[i].displayName}&handphone[${i}]=${_contactMaps[i]['phones'][0]['value']}');
      //   // print(result[i].avatar);
      //   avatar = base64.encode(result[i].avatar);
      //   // rs = rs + 'cart[]=${i}&name[${i}]=${result[i].displayName}&handphone[${i}]=${_contactMaps[i]['phones'][0]['value']}&';
      //   // print(cart);
      // }
      // print(rs);
      String apiurl = 'https://api.watchbook.tv/Addressbook/joinsProcess?'; //토큰요청
      Map<String, String> headers = {HttpHeaders.authorizationHeader : "Bearer ${tokenValue}"};
      String base = 'data:image/png;base64, ';
      var response = await http.MultipartRequest("POST",Uri.parse(apiurl),
        );
        response.headers.addAll(headers);
        print(result[0].displayName);

          if(result.length > 1){
            for(int i = 0; i < result.length-1; i++) {
              response.fields["cart[${i}]"] = "${i}";
              response.fields["name[${i}]"] = "${result[i].displayName}";
              if( _contactMaps[i]['phones'][0]['value'] == null){
                print("${i}번 빔");
                response.fields["handphone[${i}]"] = "";
              }else {
                response.fields["handphone[${i}]"] = "${phones[i]}";
                //throw RangeError.index(result.length,'default');
                // (base64.encode(result[i].avatar) == null || base64.encode(result[i].avatar) == '')
                //     ? null :
                // response.fields["picture[data][${i}]"] = "${base+base64.encode(result[i].avatar)}";
              }
            }
          }
      setState(() {
          chk = true;
        });

      var send = await response.send();
      String res = await send.stream.bytesToString();
      print(res);
      print(response.headers);
    }catch(e){
      print(e);
    }
  }
}

