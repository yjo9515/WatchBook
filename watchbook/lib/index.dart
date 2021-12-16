import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _indexPage();
  }
}

class MyHomePage extends StatefulWidget {
  late final String title;

  @override
  _indexPage createState() => _indexPage();
}

class _indexPage extends State<IndexPage> {
  Future<List<Timer>>? timerList;
  String stoptimetodisplay = '00:00:00';
  Stopwatch swatch = Stopwatch();
  late Timer timer;
  List<String> _subjectList = ['과목', '국어', '수학', '영어'];
  String _selectedSubject = '과목';
  List<String> _studyList = ['인터넷강의', '자습', '모의고사', '오답노트'];
  String _selectedStudy = '인터넷강의';

  int initial = int.parse('00');
  String timerName='';
  int hour = 0;
  int min = 0;
  int sec = 0;
  bool started = true;
  bool stopped = true;
  int timeForTimer = 0;
  String timetodisplay = "";
  bool checktimer = true;

  bool timerTrigger = true;
  bool all = true;
  bool more = false;
  bool detail = true;

  @override
  void iniState() {
    super.initState();
    // timerList = getTimerList();
  }

  // Future<List<Timer>> getTimerList() async {
  //   List<Timer> timerList;
  //   final response = await http.get(Uri.parse('http://watchbook.tv/User/loginProcess'));
  //   try{
  //     if (response.statusCode == 200) {
  //       //정상신호 일때
  //       final jsondata = utf8.decode(response.bodyBytes);
  //       timerList = jsonDecode(jsondata)['qry_result'];
  //
  //     }
  //
  //   }catch(e) {
  //     print(e);
  //   }
  //   return timerList;
  // }
  void start() {
    swatch.start();
    timer = Timer.periodic(const Duration(milliseconds: 1), update);
  }

  void update(Timer t) {
    if (swatch.isRunning) {
      setState(() {
        stoptimetodisplay = stoptimetodisplay =
            swatch.elapsed.inHours.toString().padLeft(2, '0') +
                ":" +
                (swatch.elapsed.inMinutes % 60).toString().padLeft(2, "0") +
                ":" +
                (swatch.elapsed.inSeconds % 60).toString().padLeft(2, "0");
      });
    }
  }

  void stop() {
    setState(() {
      timer.cancel();
      swatch.stop();
    });
  }

  void reset() {
    timer.cancel();
    swatch.reset();
    setState(() {
      stoptimetodisplay = "00:00:00";
    });
    _showDialog(context);

    swatch.stop();
  }

  void moreOff() {
    setState(() {
      print(more);
      more = false;
      print(more);
      return;
    });
  }

  void moreOn() {
    setState(() {
      print(more);
      more = true;
      print(more);
      return;
    });
  }

  void timeSet(){
    _timerDialog(context);
  }


  void timerStop(){
    setState(() {
      started = false;
      checktimer = false;
    });
  }

  Future timerStart() async {
    setState(() {
      started = true;
    });
    timeForTimer = ((hour * 60 * 60) + (min * 60) + sec);
    Timer.periodic(const Duration(
      seconds: 1,
    ), (Timer t){
      setState(() {
        if(timeForTimer < 1 || checktimer == false){
          t.cancel();
          if(timeForTimer == 0){
          }
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => build(context),
          ));
        }
        else{
          int h = timeForTimer ~/3600;
          int t = timeForTimer - (3600 * h);
          int m = t~/60;
          int s = t - (60*m);
          timetodisplay =
              h.toString().padLeft(2, '0')  + ":" + m.toString().padLeft(2, '0')  + ":" + s.toString().padLeft(2, '0') ;
          timeForTimer = timeForTimer -1;
        }
      });
    });
  }

  Future _showDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                '수고하셨습니다.얼마나 공부했나요?',
                style: TextStyle(
                    fontSize: 14, color: Color.fromARGB(255, 237, 243, 249)),
              ),
              backgroundColor: const Color.fromARGB(255, 42, 43, 57),
              actions: <Widget>[
                Row(
                  children: [
                    Expanded(
                        flex: 33,
                        child: Container(
                            width: 67,
                            padding: const EdgeInsets.fromLTRB(21, 32, 0, 32),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                value: _selectedSubject,
                                dropdownColor:
                                    const Color.fromARGB(255, 42, 43, 57),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedSubject = val.toString();
                                  });
                                },
                                items: _subjectList.map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color.fromARGB(255, 237, 243, 249),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ))),
                    Expanded(
                        flex: 67,
                        child: Container(
                            width: 118,
                            padding: const EdgeInsets.fromLTRB(74, 32, 0, 32),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                    value: _selectedStudy,
                                    dropdownColor:
                                        const Color.fromARGB(255, 42, 43, 57),
                                    onChanged: (val) {
                                      setState(() {
                                        print(val);
                                        _selectedStudy = val.toString();
                                      });
                                    },
                                    items: _studyList.map((value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 237, 243, 249),
                                          ),
                                        ),
                                      );
                                    }).toList()))))
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Color.fromARGB(255, 237, 243, 249)))),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: TextButton(
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 237, 243, 249),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                          )),
                      Container(
                        width: 1,
                        height: 14,
                        color: Colors.white,
                      ),
                      Expanded(
                          flex: 1,
                          child: TextButton(
                            child: const Text('확인',
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 237, 243, 249))),
                            onPressed: () => Navigator.pop(context, true),
                          ))
                    ],
                  ),
                )
              ],
            );
          });
        }).then((value) => value ?? false);
  }

  Future _timerDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: TextField(
                onChanged: (text){
                  setState((){
                    timerName = text;
                  });
                },
                style: const TextStyle(
                  color: Color.fromARGB(255, 189, 189, 189),
                ),
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Color.fromARGB(255, 189, 189, 189),
                  )),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Color.fromARGB(255, 189, 189, 189),
                  )),
                  hintText: '타이머 제목을 입력해주세요.',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 189, 189, 189),
                  ),
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 42, 43, 57),
              actions: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text(
                            '시간',
                            style: TextStyle(
                              color: Color.fromARGB(255, 237, 243, 249),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            '분',
                            style: TextStyle(
                              color: Color.fromARGB(255, 237, 243, 249),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            '초',
                            style: TextStyle(
                              color: Color.fromARGB(255, 237, 243, 249),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          child: TextFormField(
                            initialValue: '00',
                              onChanged: (text){
                                setState((){
                                  if(text == '00'){
                                    hour = 0;
                                  }else{
                                    hour = int.parse('$text');
                                  }
                                });
                              },
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 44,
                                color: Color.fromARGB(255, 237, 243, 249),
                              ),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(255, 42, 43, 57),
                                )),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(255, 42, 43, 57),
                                )),
                                hintText: '00',
                                hintStyle: TextStyle(
                                  fontSize: 44,
                                  color: Color.fromARGB(255, 237, 243, 249),
                                ),
                              )),
                        ),
                        const Text(
                          ':',
                          style: TextStyle(
                            color: Color.fromARGB(255, 237, 243, 249),
                            fontSize: 44,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          width: 100,
                          child: TextFormField(
                            initialValue: '00',
                              onChanged: (text){
                                setState((){
                                  if(text == '00'){
                                    min = 0;
                                  }else{
                                    min = int.parse('$text');
                                  }
                                });
                              },
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 44,
                                color: Color.fromARGB(255, 237, 243, 249),
                              ),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(255, 42, 43, 57),
                                )),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(255, 42, 43, 57),
                                )),
                                hintText: '00',
                                hintStyle: TextStyle(
                                  fontSize: 44,
                                  color: Color.fromARGB(255, 237, 243, 249),
                                ),
                              )),
                        ),
                        const Text(':',
                            style: TextStyle(
                              color: Color.fromARGB(255, 237, 243, 249),
                              fontSize: 44,
                            )),
                        Container(
                          width: 90,
                          child: TextFormField(
                              initialValue: '00',
                              onChanged: (text){
                                setState((){
                                  if(text == '00'){
                                    sec = 0;
                                  }else{
                                    sec = int.parse('$text');
                                  }
                                });
                              },
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 44,
                                color: Color.fromARGB(255, 237, 243, 249),
                              ),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(255, 42, 43, 57),
                                )),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color.fromARGB(255, 42, 43, 57),
                                )),
                                hintText: '00',
                                hintStyle: TextStyle(
                                  fontSize: 44,
                                  color: Color.fromARGB(255, 237, 243, 249),
                                ),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                  decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Color.fromARGB(255, 237, 243, 249)))),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: TextButton(
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 237, 243, 249),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                          )),
                      Container(
                        width: 1,
                        height: 14,
                        color: Colors.white,
                      ),
                      Expanded(
                          flex: 1,
                          child: TextButton(
                            child: const Text('등록',
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 237, 243, 249))),
                            onPressed: () => Navigator.pop(context, timerStart()),
                          ))
                    ],
                  ),
                )
              ],
            );
          });
        }).then((value) => value ?? false);
  }

  void _detailShow(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext context){
        return Container(
          width: MediaQueryData.fromWindow(
              WidgetsBinding.instance!.window)
              .size
              .width,
          height: MediaQueryData.fromWindow(
              WidgetsBinding.instance!.window)
              .size
              .height,
          color: const Color.fromARGB(255, 42, 43, 57),
          // child: Column(
          //   mainAxisSize: MainAxisSize.max,
          //   children: <Widget>[
          //     Expanded(
          //       flex: 40,
          //       child: Column(
          //
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             Text(
          //               stoptimetodisplay,
          //               style: const TextStyle(
          //                 color: const Color.fromARGB(255, 237, 243, 249),
          //                 fontSize: 44.0,
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //             Container(
          //               height: 40,
          //             ),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //               children: <Widget>[
          //                 ButtonTheme(
          //                     minWidth: 120,
          //                     height: 40,
          //                     child: RaisedButton(
          //                       shape: RoundedRectangleBorder(
          //                           side: swatch.isRunning
          //                               ? const BorderSide(
          //                               color: Color.fromARGB(
          //                                   255, 237, 243, 249))
          //                               : const BorderSide(
          //                               color: Color.fromARGB(
          //                                   255, 237, 243, 249)),
          //                           borderRadius:
          //                           BorderRadius.circular(50)),
          //                       onPressed: () {
          //                         swatch.isRunning ? stop() : start();
          //                       },
          //                       color: swatch.isRunning
          //                           ? const Color.fromARGB(
          //                           255, 42, 43, 57)
          //                           : const Color.fromARGB(
          //                           255, 237, 243, 249),
          //                       child: Text(
          //                         swatch.isRunning ? "일시정지" : "시작",
          //                         style: swatch.isRunning
          //                             ? const TextStyle(
          //                             fontSize: 14.0,
          //                             color: Color.fromARGB(
          //                                 255, 237, 243, 249))
          //                             : const TextStyle(
          //                             fontSize: 14.0,
          //                             color: Color.fromARGB(
          //                                 255, 42, 43, 57)),
          //                       ),
          //                     )),
          //                 ButtonTheme(
          //                     minWidth: 120,
          //                     height: 40,
          //                     child: RaisedButton(
          //                       shape: RoundedRectangleBorder(
          //                           side: const BorderSide(
          //                               color: Color.fromARGB(
          //                                   255, 237, 243, 249)),
          //                           borderRadius:
          //                           BorderRadius.circular(50)),
          //                       onPressed: reset,
          //                       color:
          //                       const Color.fromARGB(255, 42, 43, 57),
          //                       child: const Text(
          //                         "초기화",
          //                         style: TextStyle(
          //                           fontSize: 14.0,
          //                           color: Color.fromARGB(
          //                               255, 237, 243, 249),
          //                         ),
          //                       ),
          //                     ))
          //               ],
          //             )
          //           ]),
          //     ),
          //     Expanded(
          //       flex: 60,
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           const Text(
          //             '오늘 공부 시간',
          //             style: TextStyle(
          //                 color: Color.fromARGB(255, 237, 243, 249),
          //                 fontSize: 14),
          //           ),
          //           Container(
          //             height: 20,
          //           ),
          //           Text(
          //             stoptimetodisplay,
          //             style: const TextStyle(
          //               color: const Color.fromARGB(255, 237, 243, 249),
          //               fontSize: 30.0,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //           Accordion(
          //             maxOpenSections: 8,
          //             rightIcon: const Icon(Icons.keyboard_arrow_down,
          //                 color: Color.fromARGB(255, 237, 243, 249)),
          //             children: [
          //               AccordionSection(
          //                 contentBorderColor:
          //                 const Color.fromARGB(255, 42, 43, 57),
          //                 headerBackgroundColor:
          //                 const Color.fromARGB(255, 42, 43, 57),
          //                 contentBackgroundColor:
          //                 const Color.fromARGB(255, 42, 43, 57),
          //                 isOpen: false,
          //                 header: const Text('자세히',
          //                     style: TextStyle(
          //                         color:
          //                         Color.fromARGB(255, 237, 243, 249),
          //                         fontSize: 13)),
          //                 content: Container(
          //                   height: 170,
          //                   child: ListView(
          //                     children: [
          //                       Column(
          //                         mainAxisAlignment:
          //                         MainAxisAlignment.spaceBetween,
          //                         children: [
          //                           Container(
          //                             height: 6,
          //                           ),
          //
          //                         ],
          //                       )
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //     Container(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: <Widget>[
          //           Container(
          //             decoration: const BoxDecoration(
          //                 border: Border(
          //                     top: BorderSide(
          //                         color: Color.fromARGB(
          //                             255, 237, 243, 249)))),
          //             child: Row(
          //               children: [
          //                 Expanded(
          //                     flex: 1,
          //                     child: TextButton(
          //                       child: const Text(
          //                         '통계',
          //                         style: TextStyle(
          //                           color: const Color.fromARGB(
          //                               255, 237, 243, 249),
          //                         ),
          //                       ),
          //                       onPressed: () =>
          //                           Navigator.pop(context, false),
          //                     )),
          //                 Container(
          //                   width: 1,
          //                   height: 14,
          //                   color: Colors.white,
          //                 ),
          //                 Expanded(
          //                     flex: 1,
          //                     child: TextButton(
          //                       child: const Text('설정',
          //                           style: TextStyle(
          //                               color: const Color.fromARGB(
          //                                   255, 237, 243, 249))),
          //                       onPressed: () =>
          //                           Navigator.pop(context, true),
          //                     ))
          //               ],
          //             ),
          //           )
          //         ],
          //       ),
          //     )
          //   ],
          // ),
        );
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        // 탭의 수 설정
        length: 3,
        child: Scaffold(
          resizeToAvoidBottomInset : false,
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 42, 43, 57),
            elevation: 0,
            // TabBar 구현. 각 컨텐트를 호출할 탭들을 등록
            bottom: TabBar(
              unselectedLabelColor: const Color.fromARGB(255, 237, 243, 249),
              labelColor: const Color.fromARGB(255, 42, 43, 57),
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromARGB(255, 237, 243, 249)),
              indicatorPadding: const EdgeInsets.only(left: 30, right: 30),
              tabs: [
                const Tab(text: '알람'),
                const Tab(text: '스탑워치'),
                const Tab(text: '타이머'),
              ],
            ),
          ),
          // TabVarView 구현. 각 탭에 해당하는 컨텐트 구성
          body: TabBarView(
            children: [
              const Tab(text: '알람'),
              Tab(
                  child: Container(
                color: const Color.fromARGB(255, 42, 43, 57),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      flex: 40,
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              stoptimetodisplay,
                              style: const TextStyle(
                                color: const Color.fromARGB(255, 237, 243, 249),
                                fontSize: 44.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              height: 40,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                ButtonTheme(
                                    minWidth: 120,
                                    height: 40,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          side: swatch.isRunning
                                              ? const BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 237, 243, 249))
                                              : const BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 237, 243, 249)),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      onPressed: () {
                                        swatch.isRunning ? stop() : start();
                                      },
                                      color: swatch.isRunning
                                          ? const Color.fromARGB(
                                              255, 42, 43, 57)
                                          : const Color.fromARGB(
                                              255, 237, 243, 249),
                                      child: Text(
                                        swatch.isRunning ? "일시정지" : "시작",
                                        style: swatch.isRunning
                                            ? const TextStyle(
                                                fontSize: 14.0,
                                                color: Color.fromARGB(
                                                    255, 237, 243, 249))
                                            : const TextStyle(
                                                fontSize: 14.0,
                                                color: Color.fromARGB(
                                                    255, 42, 43, 57)),
                                      ),
                                    )),
                                ButtonTheme(
                                    minWidth: 120,
                                    height: 40,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              color: Color.fromARGB(
                                                  255, 237, 243, 249)),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      onPressed: reset,
                                      color:
                                          const Color.fromARGB(255, 42, 43, 57),
                                      child: const Text(
                                        "초기화",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Color.fromARGB(
                                              255, 237, 243, 249),
                                        ),
                                      ),
                                    ))
                              ],
                            )
                          ]),
                    ),
                    Expanded(
                      flex: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '오늘 공부 시간',
                            style: TextStyle(
                                color: Color.fromARGB(255, 237, 243, 249),
                                fontSize: 14),
                          ),
                          Container(
                            height: 20,
                          ),
                          Text(
                            stoptimetodisplay,
                            style: const TextStyle(
                              color: const Color.fromARGB(255, 237, 243, 249),
                              fontSize: 30.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Accordion(
                            maxOpenSections: 8,
                            rightIcon: const Icon(Icons.keyboard_arrow_down,
                                color: Color.fromARGB(255, 237, 243, 249)),
                            children: [
                              AccordionSection(
                                contentBorderColor:
                                    const Color.fromARGB(255, 42, 43, 57),
                                headerBackgroundColor:
                                    const Color.fromARGB(255, 42, 43, 57),
                                contentBackgroundColor:
                                    const Color.fromARGB(255, 42, 43, 57),
                                isOpen: false,
                                header: const Text('자세히',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 237, 243, 249),
                                        fontSize: 13)),
                                content: Container(
                                  height: 170,
                                  child: ListView(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                    width: 120,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Icon(Icons.timer),
                                                        const Text(
                                                            '11:14 ~ 11:14')
                                                      ],
                                                    )),
                                                const Text('00h 00m 00s')
                                              ],
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 13, 10, 13),
                                            decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 237, 243, 249),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          Container(
                                            height: 6,
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                    width: 120,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Icon(Icons.timer),
                                                        const Text(
                                                            '11:14 ~ 11:14')
                                                      ],
                                                    )),
                                                const Text('00h 00m 00s')
                                              ],
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 13, 10, 13),
                                            decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 237, 243, 249),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          Container(
                                            height: 6,
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                    width: 120,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Icon(Icons.timer),
                                                        const Text(
                                                            '11:14 ~ 11:14')
                                                      ],
                                                    )),
                                                const Text('00h 00m 00s')
                                              ],
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 13, 10, 13),
                                            decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 237, 243, 249),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          Container(
                                            height: 6,
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                    width: 120,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Icon(Icons.timer),
                                                        const Text(
                                                            '11:14 ~ 11:14')
                                                      ],
                                                    )),
                                                const Text('00h 00m 00s')
                                              ],
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 13, 10, 13),
                                            decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 237, 243, 249),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          Container(
                                            height: 6,
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                    width: 120,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Icon(Icons.timer),
                                                        const Text(
                                                            '11:14 ~ 11:14')
                                                      ],
                                                    )),
                                                const Text('00h 00m 00s')
                                              ],
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 13, 10, 13),
                                            decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 237, 243, 249),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: Color.fromARGB(
                                            255, 237, 243, 249)))),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: TextButton(
                                      child: const Text(
                                        '통계',
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 237, 243, 249),
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    )),
                                Container(
                                  width: 1,
                                  height: 14,
                                  color: Colors.white,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: TextButton(
                                      child: const Text('설정',
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 237, 243, 249))),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )),
              Tab(
                  child: Container(
                    color: const Color.fromARGB(255, 42, 43, 57),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          flex: 40,
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  timetodisplay,
                                  style: const TextStyle(
                                    color: const Color.fromARGB(255, 237, 243, 249),
                                    fontSize: 44.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  height: 40,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    ButtonTheme(
                                        minWidth: 120,
                                        height: 40,
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              side: started
                                                  ? const BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 237, 243, 249))
                                                  : const BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 237, 243, 249)),
                                              borderRadius:
                                              BorderRadius.circular(50)),
                                          onPressed: () {
                                            started ?
                                                timeSet():
                                                timerStop();

                                          },
                                          color: started
                                              ? const Color.fromARGB(
                                              255, 42, 43, 57)
                                              : const Color.fromARGB(
                                              255, 237, 243, 249),
                                          child: Text(
                                            started ? "시간설정" : "일시정지",
                                            style: started
                                                ? const TextStyle(
                                                fontSize: 14.0,
                                                color: Color.fromARGB(
                                                    255, 237, 243, 249))
                                                : const TextStyle(
                                                fontSize: 14.0,
                                                color: Color.fromARGB(
                                                    255, 42, 43, 57)),
                                          ),
                                        )),
                                    ButtonTheme(
                                        minWidth: 120,
                                        height: 40,
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 237, 243, 249)),
                                              borderRadius:
                                              BorderRadius.circular(50)),
                                          onPressed: reset,
                                          color:
                                          const Color.fromARGB(255, 42, 43, 57),
                                          child: const Text(
                                            "초기화",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: Color.fromARGB(
                                                  255, 237, 243, 249),
                                            ),
                                          ),
                                        ))
                                  ],
                                )
                              ]),
                        ),
                        Expanded(
                          flex: 60,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '오늘 공부 시간',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 237, 243, 249),
                                    fontSize: 14),
                              ),
                              Container(
                                height: 20,
                              ),
                              Text(
                                timetodisplay,
                                style: const TextStyle(
                                  color: const Color.fromARGB(255, 237, 243, 249),
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Accordion(
                                maxOpenSections: 8,
                                rightIcon: const Icon(Icons.keyboard_arrow_down,
                                    color: Color.fromARGB(255, 237, 243, 249)),
                                children: [
                                  AccordionSection(
                                    contentBorderColor:
                                    const Color.fromARGB(255, 42, 43, 57),
                                    headerBackgroundColor:
                                    const Color.fromARGB(255, 42, 43, 57),
                                    contentBackgroundColor:
                                    const Color.fromARGB(255, 42, 43, 57),
                                    isOpen: false,
                                    header: const Text('자세히',
                                        style: TextStyle(
                                            color:
                                            Color.fromARGB(255, 237, 243, 249),
                                            fontSize: 13)),
                                    content: Container(
                                      height: 170,
                                      child: ListView(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        width: 120,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            const Icon(Icons.timer),
                                                            const Text(
                                                                '11:14 ~ 11:14')
                                                          ],
                                                        )),
                                                    const Text('00h 00m 00s')
                                                  ],
                                                ),
                                                padding: const EdgeInsets.fromLTRB(
                                                    10, 13, 10, 13),
                                                decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 237, 243, 249),
                                                    borderRadius:
                                                    BorderRadius.circular(10)),
                                              ),
                                              Container(
                                                height: 6,
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        width: 120,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            const Icon(Icons.timer),
                                                            const Text(
                                                                '11:14 ~ 11:14')
                                                          ],
                                                        )),
                                                    const Text('00h 00m 00s')
                                                  ],
                                                ),
                                                padding: const EdgeInsets.fromLTRB(
                                                    10, 13, 10, 13),
                                                decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 237, 243, 249),
                                                    borderRadius:
                                                    BorderRadius.circular(10)),
                                              ),
                                              Container(
                                                height: 6,
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        width: 120,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            const Icon(Icons.timer),
                                                            const Text(
                                                                '11:14 ~ 11:14')
                                                          ],
                                                        )),
                                                    const Text('00h 00m 00s')
                                                  ],
                                                ),
                                                padding: const EdgeInsets.fromLTRB(
                                                    10, 13, 10, 13),
                                                decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 237, 243, 249),
                                                    borderRadius:
                                                    BorderRadius.circular(10)),
                                              ),
                                              Container(
                                                height: 6,
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        width: 120,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            const Icon(Icons.timer),
                                                            const Text(
                                                                '11:14 ~ 11:14')
                                                          ],
                                                        )),
                                                    const Text('00h 00m 00s')
                                                  ],
                                                ),
                                                padding: const EdgeInsets.fromLTRB(
                                                    10, 13, 10, 13),
                                                decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 237, 243, 249),
                                                    borderRadius:
                                                    BorderRadius.circular(10)),
                                              ),
                                              Container(
                                                height: 6,
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        width: 120,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            const Icon(Icons.timer),
                                                            const Text(
                                                                '11:14 ~ 11:14')
                                                          ],
                                                        )),
                                                    const Text('00h 00m 00s')
                                                  ],
                                                ),
                                                padding: const EdgeInsets.fromLTRB(
                                                    10, 13, 10, 13),
                                                decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 237, 243, 249),
                                                    borderRadius:
                                                    BorderRadius.circular(10)),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                decoration: const BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            color: Color.fromARGB(
                                                255, 237, 243, 249)))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: TextButton(
                                          child: const Text(
                                            '통계',
                                            style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 237, 243, 249),
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                        )),
                                    Container(
                                      width: 1,
                                      height: 14,
                                      color: Colors.white,
                                    ),
                                    Expanded(
                                        flex: 1,
                                        child: TextButton(
                                          child: const Text('설정',
                                              style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 237, 243, 249))),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                        ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
