import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchbookapp/main.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future<bool> _checkNotification() async {
  bool status = await Permission.notification.isGranted;
  print('알람 체크값 : ${status}');
  if (status == true) {
    return Future.value(true);
  } else {
    return Future.value(false);
  }
}

class WelcomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _welcomePage();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _welcomePage createState() => _welcomePage();
}

class _welcomePage extends State<WelcomePage> {
  @override
  void initState(){
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    super.initState();
  }
  InAppWebViewController? _webViewController;
  String url = 'http://m.watchbook.tv';
  late String msg;
  int chk = 0;
  int level = 0;
  var rs;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: level == 0 ? Container(
            width:
            MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                .size
                .width,
            //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
            height:
            MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                .size
                .height,
            child: Column(
              children: [
                chk == 0 ?
                Container(
                  width:
                  MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                      .size
                      .width - 200,
                  //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                  height: 500,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('수험자 접속 대기'),
                      const Text('1번'),
                      const Text('수험자 접속 대기'),
                    ],
                  ),
                ) :
                chk == 1 ?
                Container(
                  child:
                  Column(
                    children: [
                      const Text('1. 안내사항')
                    ],
                  ),
                ) :
                chk == 2 ?
                Container(
                  child:
                  Column(
                    children: [
                      const Text('2. 유의사항')
                    ],
                  ),
                ) :
                Container(
                  child:
                  Column(
                    children: [
                      const Text('3. 기능 설명')
                    ],
                  ),),
                SizedBox(
                  height: 48,
                  width: 120,
                  child: RaisedButton(
                    onPressed: () {
                        if(chk == 0){
                          setState(() {
                            chk = 1;
                          });
                        }else if(chk == 1){
                          setState(() {
                            chk = 2;
                          });
                        }else if(chk == 2){
                          setState(() {
                            chk = 3;
                          });
                        }else if(chk == 3){
                          setState(() {
                            chk = 0;
                          });
                        }
                        print(chk);
                    },
                    child: const Text(
                      "다음으로",
                      style: TextStyle(
                          fontSize: 16, color: Colors.white),
                    ),
                    color: const Color.fromARGB(
                        97, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ) :
          Container(
            width:
            MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                .size
                .width,
            //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
            height:
            MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                .size
                .height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 600,
                  height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                      .size
                      .height - 50,
                    child: InAppWebView(
                      initialOptions: options,
                      initialData: InAppWebViewInitialData(
                        data: r""" 
                        <!DOCTYPE html>
<html>
<head>
    <title>CBT</title>
    <meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script>
    <style>
        body > div:nth-child(1) {
            transform: translateY(-76px);
            transition: all 0.5s;
            z-index: 999999999;
            position: fixed;
            right: 0;
            top: 0;
            text-align: right;
            text-align: right;
        }

            body > div:nth-child(1) > div a {
                background: #fff;
                color: #749EE1;
                padding: 5px 34px;
                text-decoration: none;
                border: 1px solid #749EE1;
                font-size: 21px
            }

            body > div:nth-child(1) > div:nth-of-type(2) {
                background-color: #749EE1 !important;
                width: 88px;
                height: 24px;
                margin: 0 auto;
                background-repeat: no-repeat;
                background-position: 80px 6px;
                color: #fff;
                padding: 5px 16px;
                line-height: 24px;
                cursor: pointer;
                background-image: url('https://www.klata.or.kr/cdn/klata/image/cbt/down2.png');
                text-align: left;
                display: inline-block;
                background-size: 24px;
                font-size: 21px;
            }

            body > div:nth-child(1) > div:nth-of-type(1) {
                display: flex;
                width: 686px;
                z-index: 999;
                justify-content: space-between;
                background: #FFF;
                border: 1px solid #749EE1;
                padding: 16px
            }

        .slide_left {
            transform: translateY(0px) !important;
        }
    </style>    
    <style>
        @import url(//fonts.googleapis.com/earlyaccess/notosanskr.css);
        @charset "utf-8";

        * {
            margin: 0;
            padding: 0;
        }

        * {
            font-family: "Noto Sans KR", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
        }

        html, body {
            /* height: 100%;  */
            background: #FFF;
        }

        html {
            overflow-y: auto;
        }

        body {
            overflow: hidden;
        }

        li {
            list-style: none;
        }

        em, address {
            font-style: normal;
        }

        textarea {
            overflow: auto;
        }

        hr {
            display: none;
        }

        table, tr, td {
            padding: 0px;
            border-spacing: 0px;
            border-collapse: collapse;
        }

        legend {
            text-align: center !important;
            margin: 0 auto !important;
        }

        fieldset {
            border: 2px solid #000 !important;
            padding: 10px;
        }

        table {
            text-indent: initial;
            border-spacing: 2px;
        }

        .tb {
            border: 1px solid #FF0000 !important;
        }

        #sp {
            cursor: pointer;
        }

        .act {
            background-image: url('https://www.klata.or.kr/cdn/klata/image/cbt/up2.png') !important;
        }


        .article {
            width: 100%;
        }

        .r_wrap {
            top: 0;
            right: 0;
        }

        .no_article {
            width: 35% !important;
            position: fixed;
            height: 870px;
            overflow-y: scroll;
        }

        #left_btn a {
            background: #000;
            color: #FFF;
            text-decoration: none;
            padding: 15px 40px !important;
            font-size: 20px;
        }

        #left_btn {
            width: 545px;
            flex-direction: row !important;
            float: right;
            margin-right: 20px;
            margin-bottom: 10px;
        }

        table:nth-child(1) > tbody > tr > td > textarea {
            min-height: 100px;
        }

        #jsCanvas {
            position: absolute;
            top: 30px;
            opacity: 0.2;
            left: 0;
        }

        #keypad {
            display: none;
            bottom: 0;
            background: #FFF;
        }

        .toggle {
            display: table !important;
        }

        #keypad tr td {
            cursor: pointer;
            border: 1px solid #000;
            padding: 5px;
            text-align: center;
        }

        #textarea1 {
            font-size: 20px !important;
            line-height: 2;
        }

        img {
            width: 100% !important;
        }

        .text_box {
            border: 2px solid #000 !important;
            padding: 10px;
        }

        .border {
            width: 100% !important;
        }

            .border th, .border td {
                border: 1px solid #000 !important;
                font-size: 20px;
            }

        .question p {
            font-size: 20px !important;
        }

        .question_comment {
            clear: both;
            overflow: hidden;
            text-align: left;
        }

            .question_comment * {
                font-size: 12pt;
            }

            .question_comment table {
                width: 100%;
            }

            .question_comment th {
                vertical-align: top;
                line-height: 20px;
                padding: 8px 5px 7px 5px;
            }

            .question_comment td {
                vertical-align: top;
                line-height: 20px;
                padding: 8px 5px 7px 5px;
            }

            .question_comment table.border {
                border: 1px solid #000;
            }

                .question_comment table.border th {
                    border: 1px solid #000;
                }

                .question_comment table.border td {
                    border: 1px solid #000;
                }

            .question_comment .article {
                clear: both;
                overflow: hidden;
                margin: 0 0 10px 0;
            }

        .article {
            font-size: 20px;
            margin-top: 30px;
        }

        .q_wrap div.question {
            margin-top: 30px;
        }

        .question_comment .question_group {
            clear: both;
            overflow: hidden;
            padding: 5px 0;
            margin: 0;
            text-align: left;
            border: 0;
        }

            .question_comment .question_group > div {
                clear: both;
                overflow: hidden;
                border: 2px solid #000;
                padding: 9px;
                margin: 10px 0;
                text-align: left;
                min-height: 24px;
            }

        .question_comment .question {
            clear: both;
            overflow: hidden;
            padding: 0 0 0 5px;
            margin: 0;
            text-align: left;
            border: 0;
        }

            .question_comment .question p {
                line-height: 25px;
                min-height: 25px;
                text-align: justify;
            }

        .question_comment .question_content {
            clear: both;
            overflow: hidden;
            padding: 0;
            margin: 5px 0;
            text-align: left;
            border: 0;
            padding: 14px;
        }

            .question_comment .question_content > div:last-child {
                clear: both;
                overflow: hidden;
                border: 2px solid #000;
                padding: 9px;
                margin: 0;
                text-align: justify;
                min-height: 24px;
            }

        .question_comment .question_example {
            clear: both;
            overflow: hidden;
            padding: 0;
            margin: 5px 0;
            text-align: left;
            border: 0;
        }

            .question_comment .question_example > div:last-child {
                clear: both;
                overflow: hidden;
                padding: 0;
                margin: 0;
            }

                .question_comment .question_example > div:last-child > fieldset {
                    clear: both;
                    overflow: hidden;
                    border: 2px solid #000;
                    padding: 5px;
                    margin: 5px 0;
                    text-align: center;
                }

                    .question_comment .question_example > div:last-child > fieldset > legend {
                        line-height: 30px;
                        padding: 0 10px 0 10px;
                    }

                    .question_comment .question_example > div:last-child > fieldset > div {
                        clear: both;
                        overflow: hidden;
                        padding: 5px;
                        text-align: justify;
                        min-height: 24px;
                    }

        .question_comment .answer {
            clear: both;
            overflow: hidden;
            padding: 9px 0;
            margin: 0;
            text-align: left;
            border: 0;
        }

            .question_comment .answer th {
                text-align: center;
                border-right: 0;
                width: 20px;
                font-size: 20px;
                padding-right: 5px;
            }

            .question_comment .answer td {
                text-align: justify;
                font-size: 20px;
            }

        .answer th {
            font-size: 20px;
            padding: 15px 5px;
            padding-right: 5px;
            width: 50px;
        }

            .answer th > div {
                width: 50px;
            }

            .answer th div * {
                display: inline-block;
            }

        .answer td {
            font-size: 20px;
            text-align: left;
        }

        .question_comment .text_box {
            clear: both;
            overflow: hidden;
            border: 0;
            padding: 8px;
            margin: 5px 0;
            text-align: left;
            border: 2px solid #000;
            font-size: 20px;
            line-height: 2;
        }

        .question_comment .editors {
            position: absolute;
            background: #FFF;
            margin-top: 2px;
            right: 35px;
        }

            .question_comment .editors > span {
                display: inline-block;
                color: #000 !important;
                width: 18px;
                height: 18px;
                line-height: 18px;
                text-align: center;
                border: 1px solid #ddd;
                border-radius: 3px;
                margin: 2px;
                cursor: pointer;
                font-size: 15px;
            }

                .question_comment .editors > span.material-icons {
                    font-family: 'Material Icons' !important;
                }

        .question_comment .question_example > .editors {
            clear: both;
            overflow: hidden;
            text-align: right;
            margin: 5px 0 -5px 0;
        }

        .question_comment table {
            width: 100%;
        }

            .question_comment table.border th {
                border: 1px solid #000 !important;
            }

            .question_comment table.border td {
                border: 1px solid #000 !important;
            }

        .question_memo .content {
            border: 1px solid #ddd;
        }

            .question_memo .content sup.plus {
                color: #FF0000;
            }

            .question_memo .content sup.minus {
                color: blue;
            }

            .question_memo .content span[data-points="0"] sup {
                display: none;
            }

            .question_memo .content > span::after {
                content: '/';
                margin: 0 5px;
            }

            .question_memo .content > span:last-of-type::after {
                display: none;
            }

            .question_memo .content > span > ul.samewords {
                display: inline-block;
                width: 0;
                height: 0;
                border-left: 4px solid transparent;
                border-right: 4px solid transparent;
                border-top: 8px solid #333;
            }

                .question_memo .content > span > ul.samewords li {
                    display: none;
                }

            .question_memo .content > div {
                border-top: 1px dotted #ddd;
                padding: 14px;
            }

            .question_memo .content .grammer span {
                border: 1px solid #ddd;
                padding: 3px 5px 2px 5px;
                margin: 0 10px 0 5px;
            }

            .question_memo .content .wording span {
                border: 1px solid #ddd;
                padding: 3px 5px 2px 5px;
                margin: 0 10px 0 5px;
            }

            .question_memo .content .string_length span {
                border: 1px solid #ddd;
                padding: 3px 5px 2px 5px;
            }

            .question_memo .content .structure label {
                color: #666;
            }

            .question_memo .content .structure span {
                border: 1px solid #ddd;
                padding: 3px 5px 2px 5px;
                margin: 0 10px 0 5px;
            }

        #tbl_question_list a {
            color: #000;
        }

            #tbl_question_list a.over {
                font-weight: bold;
            }

        .question_input {
            clear: both;
            overflow: hidden;
        }

            .question_input * {
                font-family: "Noto Sans CJK KR", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
            }

            .question_input table {
                width: 100%;
            }

            .question_input th {
                vertical-align: top;
                line-height: 20px;
                padding: 8px 5px 7px 5px;
            }

            .question_input td {
                vertical-align: middle;
                line-height: 20px;
                padding: 8px 5px 7px 5px;
            }

            .question_input div > label {
                display: table-cell;
            }

            .question_input div > span {
                display: table-cell;
            }

            .question_input table.border > tbody > tr > th {
                border: 1px solid #000 !important;
            }

            .question_input table.border > tbody > tr > td {
                border: 1px solid #000 !important;
            }

            .question_input table.border > tr > th {
                border: 1px solid #000 !important;
            }

            .question_input table.border > tr > td {
                border: 1px solid #000 !important;
            }

            .question_input table.sentence > tbody > tr > th {
                border: 1px dotted #ddd !important;
                white-space: nowrap;
                text-align: left;
                line-height: 25px;
            }

            .question_input table.sentence > tbody > tr > td {
                border: 1px dotted #ddd !important;
                width: 100%;
                text-align: left;
                line-height: 25px;
            }

            .question_input table.sentence > tr > th {
                border: 1px dotted #ddd !important;
                white-space: nowrap;
                text-align: left;
                line-height: 25px;
            }

            .question_input table.sentence > tr > td {
                border: 1px dotted #ddd !important;
                width: 100%;
                text-align: left;
                line-height: 25px;
            }

            .question_input .article {
                clear: both;
                overflow: hidden;
                border: 1px dotted #FF0000;
                margin: 0 0 10px 0;
                text-align: left;
            }

            .question_input .question_group {
                clear: both;
                overflow: hidden;
                padding: 5px 0;
                margin: 0;
                text-align: left;
                border: 1px dotted #ddd;
                margin-bottom: 25px;
            }

                .question_input .question_group > div {
                    clear: both;
                    overflow: hidden;
                    border: 2px solid #000;
                    padding: 9px;
                    margin: 0;
                    text-align: left;
                    min-height: 24px;
                }

            .question_input .question {
                clear: both;
                overflow: hidden;
                padding: 0;
                margin: 5px 0;
                text-align: left;
                border: 0;
            }

                .question_input .question p {
                    line-height: 25px;
                    min-height: 25px;
                    border: 1px dotted #ddd;
                    text-align: justify;
                }

            .question_input .question_content {
                clear: both;
                overflow: hidden;
                padding: 0;
                margin: 5px 0;
                text-align: left;
                border: 0;
            }

                .question_input .question_content > div:last-child {
                    clear: both;
                    overflow: hidden;
                    border: 2px solid #000;
                    padding: 9px;
                    margin: 0;
                    text-align: justify;
                    min-height: 24px;
                }

            .question_input .question_example {
                clear: both;
                overflow: hidden;
                padding: 0;
                margin: 5px 0;
                text-align: left;
                border: 0;
            }

                .question_input .question_example > div:last-child {
                    clear: both;
                    overflow: hidden;
                    border: 1px dotted #ddd;
                    padding: 0;
                    margin: 0;
                }

                    .question_input .question_example > div:last-child > fieldset {
                        clear: both;
                        overflow: hidden;
                        border: 2px solid #000 !important;
                        padding: 5px;
                        margin: 5px 0;
                        text-align: center !important;
                    }

                        .question_input .question_example > div:last-child > fieldset > legend {
                            line-height: 30px;
                            padding: 0 10px 0 10px;
                            text-align: center;
                        }

                        .question_input .question_example > div:last-child > fieldset > div {
                            clear: both;
                            overflow: hidden;
                            border: 1px dotted #ddd;
                            padding: 5px;
                            text-align: justify;
                            min-height: 24px;
                        }

            .question_input .answer {
                clear: both;
                overflow: hidden;
                padding: 9px 0;
                margin: 0;
                text-align: left;
                border: 0;
            }

                .question_input .answer th {
                    text-align: center;
                    border-right: 0;
                    width: 20px;
                    border: 1px dotted #ddd !important;
                }

                    .question_input .answer th input {
                        display: none;
                    }

                .question_input .answer td {
                    text-align: justify;
                    border: 1px dotted #ff0000 !important;
                }

            .question_input .text_box {
                clear: both;
                overflow: hidden;
                border: 0;
                padding: 8px;
                margin: 5px 0;
                text-align: left;
                border: 2px solid #000 !important;
            }

            .question_input .editors {
                position: absolute;
                background: #FFF;
                margin-top: 2px;
                right: 35px;
            }

                .question_input .editors > span {
                    display: inline-block;
                    color: #000 !important;
                    width: 18px;
                    height: 18px;
                    line-height: 18px;
                    text-align: center;
                    border: 1px solid #ddd;
                    border-radius: 3px;
                    margin: 2px;
                    cursor: pointer;
                    font-size: 15px;
                }

                    .question_input .editors > span.material-icons {
                        font-family: 'Material Icons' !important;
                    }

            .question_input .question_example > .editors {
                clear: both;
                overflow: hidden;
                text-align: right;
                margin: 5px 0 -5px 0;
            }

        .question_output {
            clear: both;
            overflow: hidden;
        }

            .question_output * {
                font-family: "Noto Sans CJK KR", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
            }

            .question_output table {
                width: 100%;
            }

            .question_output th {
                vertical-align: top;
                line-height: 20px;
                padding: 8px 5px 7px 5px;
            }

            .question_output td {
                vertical-align: middle;
                line-height: 20px;
                padding: 8px 5px 7px 5px;
            }

            .question_output div > label {
                display: table-cell;
            }

            .question_output div > span {
                display: table-cell;
            }

            .question_output table.border > tbody > tr > th {
                border: 1px solid #000 !important;
            }

            .question_output table.border > tbody > tr > td {
                border: 1px solid #000 !important;
            }

            .question_output table.border > tr > th {
                border: 1px solid #000 !important;
            }

            .question_output table.border > tr > td {
                border: 1px solid #000 !important;
            }

            .question_output table.sentence > tbody > tr > th {
                border: 0;
                white-space: nowrap;
                text-align: left;
                line-height: 25px;
            }

            .question_output table.sentence > tbody > tr > td {
                border: 0;
                width: 100%;
                text-align: left;
                line-height: 25px;
            }

            .question_output table.sentence > tr > th {
                border: 0;
                white-space: nowrap;
                text-align: left;
                line-height: 25px;
            }

            .question_output table.sentence > tr > td {
                border: 0;
                width: 100%;
                text-align: left;
                line-height: 25px;
            }

            .question_output .article {
                clear: both;
                overflow: hidden;
                border: 0;
                margin: 0 0 10px 0;
                text-align: left;
            }

            .question_output .question_group {
                clear: both;
                overflow: hidden;
                padding: 5px 0;
                margin: 0;
                text-align: left;
                border: 0;
                margin-bottom: 25px;
            }

                .question_output .question_group > div {
                    clear: both;
                    overflow: hidden;
                    border: 2px solid #000;
                    padding: 9px;
                    margin: 0;
                    text-align: left;
                    min-height: 24px;
                }

            .question_output .question {
                clear: both;
                overflow: hidden;
                padding: 0;
                margin: 5px 0;
                text-align: left;
                border: 0;
            }

                .question_output .question p {
                    line-height: 25px;
                    min-height: 25px;
                    border: 0;
                    text-align: justify;
                }

            .question_output .question_content {
                clear: both;
                overflow: hidden;
                padding: 0;
                margin: 5px 0;
                text-align: left;
                border: 0;
            }

                .question_output .question_content > div:last-child {
                    clear: both;
                    overflow: hidden;
                    border: 2px solid #000;
                    padding: 9px;
                    margin: 0;
                    text-align: justify;
                    min-height: 24px;
                }

            .question_output .question_example {
                clear: both;
                overflow: hidden;
                padding: 0;
                margin: 5px 0;
                text-align: left;
                border: 0;
            }

                .question_output .question_example > div:last-child {
                    clear: both;
                    overflow: hidden;
                    border: 0;
                    padding: 0;
                    margin: 0;
                }

                    .question_output .question_example > div:last-child > fieldset {
                        clear: both;
                        overflow: hidden;
                        border: 2px solid #000;
                        padding: 5px;
                        margin: 5px 0;
                        text-align: center;
                    }

                        .question_output .question_example > div:last-child > fieldset > legend {
                            line-height: 30px;
                            padding: 0 10px 0 10px;
                            text-align: center;
                        }

                        .question_output .question_example > div:last-child > fieldset > div {
                            clear: both;
                            overflow: hidden;
                            border: 0;
                            padding: 5px;
                            text-align: justify;
                            min-height: 24px;
                        }

            .question_output .answer {
                clear: both;
                overflow: hidden;
                padding: 10px 0;
                margin: 0;
                text-align: left;
                border: 0;
            }

                .question_output .answer th {
                    text-align: center;
                    border-right: 0;
                    width: 20px;
                    border: 0;
                    text-align: right;
                }

                    .question_output .answer th div {
                        justify-content: end;
                    }

                    .question_output .answer th input {
                        display: none;
                    }

                .question_output .answer td {
                    text-align: justify;
                    border: 0;
                    text-align: left;
                }

            .question_output .text_box {
                clear: both;
                overflow: hidden;
                border: 0;
                padding: 8px;
                margin: 5px 0;
                text-align: left;
                border: 2px solid #000;
            }

            .question_output .editors {
                position: absolute;
                background: #FFF;
                margin-top: 2px;
                right: 35px;
            }

                .question_output .editors > span {
                    display: inline-block;
                    color: #000 !important;
                    width: 18px;
                    height: 18px;
                    line-height: 18px;
                    text-align: center;
                    border: 1px solid #ddd;
                    border-radius: 3px;
                    margin: 2px;
                    cursor: pointer;
                    font-size: 15px;
                }

                    .question_output .editors > span.material-icons {
                        font-family: 'Material Icons' !important;
                    }

            .question_output .question_example > .editors {
                clear: both;
                overflow: hidden;
                text-align: right;
                margin: 5px 0 -5px 0;
            }

        .answer td {
            cursor: pointer !important;
            padding: 15px 5px;
        }

        .answer th {
            font-size: 22px !important;
        }

        .answer table {
            width: 100% !important;
        }

        .question_memo .content {
            border: 1px solid #ddd;
        }

            .question_memo .content sup.plus {
                color: #FF0000;
            }

            .question_memo .content sup.minus {
                color: blue;
            }

            .question_memo .content span[data-points="0"] sup {
                display: none;
            }

            .question_memo .content > span::after {
                content: '/';
                margin: 0 5px;
            }

            .question_memo .content > span:last-of-type::after {
                display: none;
            }

            .question_memo .content > span > ul.samewords {
                display: inline-block;
                width: 0;
                height: 0;
                border-left: 4px solid transparent;
                border-right: 4px solid transparent;
                border-top: 8px solid #333;
            }

                .question_memo .content > span > ul.samewords li {
                    display: none;
                }

            .question_memo .content > div {
                border-top: 1px dotted #ddd;
                padding: 14px;
            }

            .question_memo .content .grammer span {
                border: 1px solid #ddd;
                padding: 3px 5px 2px 5px;
                margin: 0 10px 0 5px;
            }

            .question_memo .content .wording span {
                border: 1px solid #ddd;
                padding: 3px 5px 2px 5px;
                margin: 0 10px 0 5px;
            }

            .question_memo .content .string_length span {
                border: 1px solid #ddd;
                padding: 3px 5px 2px 5px;
            }

            .question_memo .content .structure label {
                color: #666;
            }

            .question_memo .content .structure span {
                border: 1px solid #ddd;
                padding: 3px 5px 2px 5px;
                margin: 0 10px 0 5px;
            }

        #tbl_question_list a {
            color: #000;
        }

            #tbl_question_list a.over {
                font-weight: bold;
            }
    </style>
</head>
<script>
        function getAnswer() {
            var answer = $('input[name=answer]:checked').val();
            var jbHtml = $('html').html();
            return '{"testing_time_line_id":"210","testingTimeObj":{"testing_time_id":"251","code":"OBJECT01"},"sortNum":"1","answer":"' + answer + '","html":"' + jbHtml + '"}';
        }   
        var isFlutterInAppWebViewReady = false;
        
        window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {            
                                                                                                                                                                                                             
        });
                
        function requestNextQuestion() {            
            window.flutter_inappwebview.callHandler('requestNextQuestion', getAnswer());
        }       
                                                                                                                                                                                                                              
        $(document).on('click', 'input[name=answer]', function () { requestStopProcess(); });
        $(document).on('click', '.answer td', function () {
            if ($(this).prev().is('th')) {
                $(this).prev().children('input[name=answer]').prop('checked', true);
                requestStopProcess();
            } else if ($(this).prev().prev().is('th')) {
                $(this).prev().prev().children('input[name=answer]').prop('checked', true);
                requestStopProcess();
            } else if ($(this).prev().prev().prev().is('th')) {
                $(this).prev().prev().prev().children('input[name=answer]').prop('checked', true);
                requestStopProcess();
            }
        });

        function capturekey() {
            var pressedKey = tring.fromCharCode(event.keyCode).toLowerCase();
            if (event.ctrlKey) { event.returnValue = false; }
            if (event.altKey) { event.returnValue = false; }
        }

        document.onkeydown = capturekey;
    </script>
<body oncontextmenu="return false" oncopy="return false" oncut="return false">
    <div>
        <div>
            <a href="" onclick="requestClearCanvas(); return false;">전체 지우기</a>
            <a href="" class="controller" id="pencil" onclick="return false;">형광펜 쓰기</a>
            <a href="" class="controller" id="undo" onclick=" return false;">되돌리기</a>
            <a href="" class="controller" id="redo" onclick="return false;">다시실행</a>
        </div>
        <div>
            펜도구
        </div>
    </div>

    <canvas id="jsCanvas" class="canvas">
    </canvas><div class="article"><div class="question_group"><p><b>※ 다음 글을 읽고 물음에 답하시오. </b></p><p><b><br></b></p><div style="border:1px solid #000;" class="text_box"><p style=""></p><div style="text-align: center; border: 1px solid rgb(0, 0, 0);" class="text_box"><b>㉠</b><p></p></div><p style="text-align: justify; "><b>(가)</b> 금융위원회는 혁신금융서비스 지정, 이른바 '금융규제 샌드박스'를 도입해 현재까지 총 77건의 서비스를 지정했다. 금융규제 샌드박스는 규제에 막혀 새로운 서비스를 현실화하지 못하는 일이 없도록 한시적으로 제한을 풀어주는 것이다. 42개의 핀테크 기업들이 지정되었고, 36건의 서비스가 작년에 시장에 출시돼 테스트를 진행하고 있다. 혁신금융서비스로 지정된 기업 중 23곳에서 총 225명의 고용이 증가했고, 11개 핀테크 기업이 약 1,200억 원 규모의 투자를 유치하는 부수적인 효과도 발생했다. 또 7개 기업이 동남아, 영국, 일본, 홍콩 등 해외에 진출하거나 이들 나라와 협의를 진행하기도 했다. 더불어 혁신금융서비스로 지정된 기업들의 증시 상장 기회도 확대됐다. 해당 기업이 '기술특례상장'으로 코스닥 시장에 상장할 때 각종 평가 항목에서 우대받을 수 있도록 지원하는 것이다.</p><p style="text-align: justify; "><br></p><p style="text-align: center;"><b><span style="font-size: 18px;">오픈뱅킹, 은행과 무한경쟁 체제, 결제·송금 넘어 영역 확대</span></b></p><p style="text-align: justify; "><br></p><p style="text-align: justify; "><b>(나)</b> 지난해 전면 시행된 오픈뱅킹은 핀테크 업체에 또 다른 기회의 장을 마련해줬다. 그간 핀테크 기업은 은행과 제휴해 펌뱅킹망을 이용하면서 막대한 수수료를 내야 했으나, 오픈뱅킹으로 은행망 이용 수수료가 기존 대비 10분의 1 수준으로 낮아지게 됐다. 수수료가 줄어들면서 송금을 주력으로 내세운 핀테크 업체의 경쟁력은 더욱 높아질 것이라는 분석이 나온다.</p><p style="text-align: justify; "><span style="font-size: 14px;"><br></span></p><p style="text-align: justify; "><span style="font-size: 14px;">* 금융규제 샌드박스(Regulatory Sandbox): 금융 소비자와 금융시장을 위협하지 않는 범위 내에서 금융회사 등이 혁신적인 금융 서비스를 실제 시장에 출시해볼 수 있도록 일시적으로 규제를 유예 또는 면제해주는 제도</span></p><p style="text-align: justify;"><span style="font-size: 14px;">* 샌드박스(Sandbox): 어린이들이 원하는 것을 마음껏 만들고 놀 수 있는 모래 놀이터에서 유래</span></p></div></div><div class="question"><p><b>1. 윗글의 ㉠에 쓸 (가) 문단의 소제목으로 가장 적절한 것은?</b></p></div><div class="answer"><table><tbody><tr><th><input type="radio" name="answer" value="1" id="q1" testing_time_line_id="210" /><label for="q1">①</label></th><td>작년 한 해 42개 핀테크 기업이 시장에 출시, 금융 혁신</td></tr><tr><th><input type="radio" name="answer" value="2" id="q2" testing_time_line_id="210" /><label for="q2">②</label></th><td>출발부터 삐끗, 핀테크 산업의 명암에 우려의 목소리 커져</td></tr><tr><th><input type="radio" name="answer" value="3" id="q3" testing_time_line_id="210" /><label for="q3">③</label></th><td>금융규제 샌드박스로 제한 풀어주니 고용 늘고, 투자도 유치</td></tr><tr><th><input type="radio" name="answer" value="4" id="q4" testing_time_line_id="210" /><label for="q4">④</label></th><td>금융규제 샌드박스로 지정된 기업들의 증시 상장으로 파급력 행사</td></tr><tr><th><input type="radio" name="answer" value="5" id="q5" testing_time_line_id="210" /><label for="q5">⑤</label></th><td>금융위원회, 총 77건의 서비스가 가능한 금융규제 샌드박스 지정 예정</td></tr></tbody></table></div></div>
</body>
<script>
    function getSize() {
        size = $(".article").css("font-size");
        size = parseInt(size, 10);
        $("#font-size").text(size);
    }
    getSize();

    var canvas = document.getElementById('jsCanvas');
    function requestClearCanvas() {
        // canvas
        var cnvs = document.getElementById('jsCanvas');
        // context
        var ctx = canvas.getContext('2d');

        // 픽셀 정리
        ctx.clearRect(0, 0, cnvs.width, cnvs.height);
        // 컨텍스트 리셋
        ctx.beginPath();
    }
    function requestPlus() {
        if ((size + 2) <= 50) {
            $(".article").css("font-size", "+=2");
            // $( "#font-size" ).text(  size += 2 );
        }
    }

    function requestMinus() {
        if ((size - 2) >= 12) {
            $(".article").css("font-size", "-=2");
            //   $( "#font-size" ).text(  size -= 2  );
        }
    }

    function requestSpecial() {
        $('#keypad').toggleClass('toggle');
    }

    function requestColumn() {
        var k = $('.question, .answer').wrapAll('<div class="r_wrap"></div>');
        $('.d').append('<div class="o"></div>');
        $('.o').append($('.r_wrap'));
        $('.answer, .question').css('margin-top', '50px');
        if ($('body').find('div').hasClass('article')) {
            $('.article').css('width', 'calc(65% - 25px)');
            $('.r_wrap').addClass('no_article');
        }
        var canvas = document.getElementById('jsCanvas');
        let element = document.querySelector('.article');
        canvas.width = element.clientWidth;
        canvas.height = element.clientHeight;
        var ctx = canvas.getContext('2d');
        ctx.strokeStyle = "#FFDB23";
        ctx.lineWidth = 15;
    }

    function requestRow() {
        if ($('body').find('div').hasClass('article')) {
            $('.article').css('width', '100%');
            $('.r_wrap').removeClass('no_article');
        }
        $('.article').append($('.answer'));
        $('.answer, .question').css('margin-top', '0px');
        var canvas = document.getElementById('jsCanvas');
        let element
        if ($('.article').find('div').hasClass('question_group')) {
            element = document.querySelector('.question_group');
        } else {
            element = document.querySelector('.article');
        }
        canvas.width = element.clientWidth;
        canvas.height = element.clientHeight;
        var ctx = canvas.getContext('2d');
        ctx.strokeStyle = "#FFDB23";
        ctx.lineWidth = 15;
    }
    $(document).ready(function () {
        $('body > div:nth-child(1) > div:nth-child(2)').click(function () {
            $('body > div:nth-child(1)').toggleClass('slide_left');
            $('body > div:nth-child(1) > div:nth-child(2)').toggleClass('act');
        });

    });

</script>
<script>
    let element;
    if ($('.article').children('div').hasClass('answer')) {
        $('.article > div:not(.answer)').wrapAll('<div class="q_wrap"></div>');
        element = document.querySelector('.q_wrap');
    } else if ($('.article').children('.question')) {
        $('.article > div > div:not(.answer)').wrapAll('<div class="q_wrap"></div>');
        element = document.querySelector('.q_wrap');
    }
</script>    
</html>
                        """,
                      ),
                      onWebViewCreated: (controller){
                        _webViewController = controller;
                        _webViewController!.addJavaScriptHandler(handlerName: 'requestNextQuestion', callback: (args) {
                          print(args);
                          setState(() {
                            rs = args;
                          });
                          nextQuestion();
                        });
                      },
                    )

                ),
                Container(
                  width: 300,
                  height:
                  MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                      .size
                      .width - 50,
                  child: Row(
                    children: [
                      SizedBox(
                          height: 120,
                          width: 48,
                          child: RaisedButton(
                            onPressed: () {
                            },
                            child: const Text(
                              "답\n안\n지",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            color: const Color.fromARGB(
                                97, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )),
                      Container(
                        width: 200,
                        height:
                        MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                            .size
                            .height - 50,
                        color: Colors.red,
                        child:
                        Column(
                          children: [
                            Container(
                              height: 30,
                              child: const Text('답안지'),
                            ),
                            Container(
                              width: 400,
                              height:
                              MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                                  .size
                                  .height - 200,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          const TextButton(
                                              onPressed: null,
                                              child: Text('서1')
                                          ),
                                          Container(
                                            width:100,
                                            child:const TextField(
                                            )
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ),
          appBar:
          AppBar(
            backgroundColor: Colors.white,
            leadingWidth: 150,
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.network('https://watchbook.tv/image/app/nav/logo.png',
                  width: 87,
                  height: 18,
                ),
                const Text('도움말',style: TextStyle(
                    fontSize: 16, color: Colors.black),
                )
              ],
            ),
            iconTheme: const IconThemeData(color:Color.fromARGB(255, 0, 104, 166)),
            title: const Text('수험번호 | 성명',style: TextStyle(
                fontSize: 16, color: Colors.black)),
            centerTitle: true,
            actions: [
              SizedBox(
                height: 48,
                width: 120,
                child: RaisedButton(
                  onPressed: () {
                    if(level == 0){
                      setState(() {
                        level = 1;
                      });
                    }else if(level == 1){
                      setState(() {
                        level = 2;
                      });
                    }else if(level == 2){
                      setState(() {
                        level = 3;
                      });
                    }else if(level == 3){
                      setState(() {
                        level = 0;
                      });
                    }
                  },
                  child: level == 0 ? const Text(
                    "시험시작",
                    style: TextStyle(
                        fontSize: 16, color: Colors.white),
                  ) : const Text(
                    "시험종료",
                    style: TextStyle(
                        fontSize: 16, color: Colors.white),
                  ),
                  color: const Color.fromARGB(
                      97, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                width: 120,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder:
                                (BuildContext context) =>
                                LoginPage()));
                  },
                  child: const Text(
                    "제출하기",
                    style: TextStyle(
                        fontSize: 16, color: Colors.white),
                  ),
                  color: const Color.fromARGB(
                      97, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            ],
          ),
            bottomNavigationBar:
            Row(
              children: [
              SizedBox(
              height: 48,
              width: 120,
              child: RaisedButton(
                onPressed: () {
                },
                child: const Text(
                  "장애신고",
                  style: TextStyle(
                      fontSize: 16, color: Colors.white),
                ),
                color: const Color.fromARGB(
                    97, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),),
                SizedBox(
                  height: 48,
                  width: 120,
                  child: RaisedButton(
                    onPressed: () {
                      String requestColumn = r""" 
                       requestRow(); 
                      """;
                      _webViewController!.callAsyncJavaScript(functionBody: requestColumn);
                    },
                    child: const Text(
                      "가로보기",
                      style: TextStyle(
                          fontSize: 16, color: Colors.white),
                    ),
                    color: const Color.fromARGB(
                        97, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),),
                SizedBox(
                  height: 48,
                  width: 120,
                  child: RaisedButton(
                    onPressed: () {
                      String requestColumn = r""" 
                         requestColumn(); 
                        """;
                      _webViewController!.callAsyncJavaScript(functionBody: requestColumn);
                    },
                    child: const Text(
                      "세로보기",
                      style: TextStyle(
                          fontSize: 16, color: Colors.white),
                    ),
                    color: const Color.fromARGB(
                        97, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),),
                Container(
                  width: 200,
                  child:
                    Row(
                      children: [
                        const Text('글자크기'),
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: RaisedButton(
                            onPressed: () {
                              String requestColumn = r""" 
                               requestPlus(); 
                              """;
                              _webViewController!.callAsyncJavaScript(functionBody: requestColumn);
                            },
                            child: const Text(
                              "+",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            color: const Color.fromARGB(
                                97, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),),
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: RaisedButton(
                            onPressed: () {
                              String requestColumn = r""" 
                               requestMinus(); 
                              """;
                              _webViewController!.callAsyncJavaScript(functionBody: requestColumn);
                            },
                            child: const Text(
                              "-",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            color: const Color.fromARGB(
                                97, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),)
                      ],
                    )
                ),
                SizedBox(
                  height: 48,
                  width: 120,
                  child: RaisedButton(
                    onPressed: () {
                      String requestColumn = r""" 
                       requestSpecial(); 
                      """;
                      _webViewController!.callAsyncJavaScript(functionBody: requestColumn);
                    },
                    child: const Text(
                      "특수문자",
                      style: TextStyle(
                          fontSize: 16, color: Colors.white),
                    ),
                    color: const Color.fromARGB(
                        97, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),),
                SizedBox(
                  height: 48,
                  width: 120,
                  child: RaisedButton(
                    onPressed: () {
                      String requestColumn = r""" 
                       requestNextQuestion();
                      """;
                      _webViewController!.callAsyncJavaScript(functionBody: requestColumn);
                    },
                    child: const Text(
                      "이전 문제",
                      style: TextStyle(
                          fontSize: 16, color: Colors.white),
                    ),
                    color: const Color.fromARGB(
                        97, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),),
              ],
            )
        ));
  }

  Future<bool> _goBack(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('와치북을 종료하시겠어요?'),
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

  void logoutProcess() async{
    SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
        await sharedPreferences.remove('token');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => MyApp()),
            (Route<dynamic> route) => false);
  }
}

  void nextQuestion() {

  }

