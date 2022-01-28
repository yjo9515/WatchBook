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
  bool chk = false; // 약관동의 및 전화전호부 등록
  @override
  void initState() {
    _askPermissions();
    super.initState();
  }

  _askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      downloadList();
    } else {
      _contact = await ContactsService.getContacts();
      result = _contact.toList();
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const snackBar = const SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const snackBar =
      const SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

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
      _contact = await ContactsService.getContacts();
      result = _contact.toList();
      print(chk);
      List _contactMaps = result.map((e) => e.toMap()).toList();
      print(_contactMaps);
      print(result.length);
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String? tokenValue = sharedPreferences.getString('token');
      String rs = '';
      String avatar = '';
      for(int i = 0; i < result.length; i++ ){
        // print('${i}');
        // print(result[i].displayName);
        // print(_contactMaps[i]['phones'][0]['value']);
        //print('cart[]=${i}&name[${i}]=${result[i].displayName}&handphone[${i}]=${_contactMaps[i]['phones'][0]['value']}');
        // print(result[i].avatar);
        avatar = base64.encode(result[i].avatar);
        print('$avatar');
        rs = rs + 'cart[]=${i}&name[${i}]=${result[i].displayName}&handphone[${i}]=${_contactMaps[i]['phones'][0]['value']}&';
        // print(cart);
      }
      print(rs);
      String apiurl = 'https://api.watchbook.tv/Addressbook/joinsProcess?'; //토큰요청
      Map<String, String> headers = {HttpHeaders.authorizationHeader : "Bearer ${tokenValue}"};
      print(apiurl);
      print(base64.encode(result[11].avatar));
      String base = 'data:image/png;base64, ';
      print('${base+base64.encode(result[11].avatar)}');


      var response = await http.MultipartRequest("POST",Uri.parse(apiurl),
        );
        response.headers.addAll(headers);
      for(int i = 0; i < result.length; i++){
        response.fields["cart[${i}]"] = "${i}";
        response.fields["name[${i}]"] = "${result[i].displayName}";
        response.fields["handphone[${i}]"] = "${_contactMaps[i]['phones'][0]['value']}";
        (base64.encode(result[i].avatar) == null || base64.encode(result[i].avatar) == '')
            ? null :
        response.fields["picture[data][${i}]"] = "${base+base64.encode(result[i].avatar)}";
      }
      var send = await response.send();
      String res = await send.stream.bytesToString();
      print(res);
      print(response.headers);

      setState(() {
        chk = true;
      });
    }catch(e){
      print(e);
    }
  }
}