import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:weekday_selector/weekday_selector.dart';

class AlarmPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _alarmPage();
  }
}

class MyHomePage extends StatefulWidget {
  late final String title;

  @override
  _alarmPage createState() => _alarmPage();
}

class _alarmPage extends State<AlarmPage> {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  String? _selectedTime;
  DateTime? _selectedDate;
  int? _hour;
  int? _minute;
  Time? _time;
  final values = List.filled(7, true);
  var filiterValues;
  late int index;

  void initState() {
    super.initState();
    callPermissions();
    var androidSetting =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSetting = const IOSInitializationSettings(
      requestSoundPermission: false,
      requestAlertPermission: false,
      requestBadgePermission: false,
    );
    var initializationSettings =
    InitializationSettings(android: androidSetting, iOS: iosSetting);

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {});
  }

  Future<String> callPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
    ].request();

    if (statuses.values.every((element) => element.isGranted)) {
      return 'success';
    } else {
      openAppSettings();
      return 'fail';
    }
  }

  Future<void> _show() async {
    final TimeOfDay? result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      helpText: '시간을 설정해주세요',
      cancelText: '취소',
      confirmText: '설정',
      hourLabelText: '시',
      minuteLabelText: '분',
    );

    if (result != null) {
      setState(() {
        _selectedTime = result.format(context);
        _hour = result.hour.toInt();
        print(_hour);
        _minute = result.minute.toInt();
        print(_minute);
        _time = new Time(_hour!, _minute!, 00);
        if (_selectedTime == null) {
          _selectedTime == '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내부알람설정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WeekdaySelector(
              onChanged: (int day) {
                setState(() {
                  // Use module % 7 as Sunday's index in the array is 0 and
                  // DateTime.sunday constant integer value is 7.
                  index = day % 7;
                  // We "flip" the value in this example, but you may also
                  // perform validation, a DB write, an HTTP call or anything
                  // else before you actually flip the value,
                  // it's up to your app's needs.
                  print(day);
                  print(index);
                  print(values);
                  filiterValues = values.where((e) => e != false);
                  print(filiterValues);
                  values[index] = !values[index];
                });
              },
              values: values,
            )
            ,
            RaisedButton(
              child: const Text('적용'),
              onPressed: _dailyAtTimeNotification,
            ),
            TimePickerSpinner(
              is24HourMode: false,
              normalTextStyle:
              const TextStyle(fontSize: 24, color: Color.fromARGB(
                  255, 85, 87, 114),),
              highlightedTextStyle:
              const TextStyle(fontSize: 24, color: Colors.yellow),
              spacing: 50,
              itemHeight: 80,
              isForce2Digits: true,
              onTimeChange: (time) {
                setState(() {
                  if (time != null) {
                    _hour = time.hour.toInt();
                    print(_hour);
                    _minute = time.minute.toInt();
                    print(_minute);
                    _time = new Time(_hour!, _minute!, 00);
                  }
                });
              },
            ),
            RaisedButton(
              child: const Text('취소'),
              onPressed: () => _flutterLocalNotificationsPlugin.cancelAll(),
            ),
          ],
        ),
      ),
    );
  }

  Future _dailyAtTimeNotification() async {
    const notiTitle = 'title';
    const notiDesc = 'description';

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    var android = const AndroidNotificationDetails('id', notiTitle,
        importance: Importance.max, priority: Priority.max);
    var ios = const IOSNotificationDetails();
    var detail = NotificationDetails(android: android, iOS: ios);

    if (result != null) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.deleteNotificationChannelGroup('id');
        filiterValues = values.where((e) => e != false);
        print(filiterValues);
      int notiKey = 0;
      for(int i = 0; i < filiterValues.length; i++){
        await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
            notiKey++, notiTitle, notiDesc, Day.values[index], _time! , detail);
      }



      // await flutterLocalNotificationsPlugin.zonedSchedule(
      //   1, // id는 unique해야합니다. int값
      //   notiTitle,
      //   notiDesc,
      //   _setNotiTime(_time!),
      //   detail,
      //
      //   androidAllowWhileIdle: true,
      //   uiLocalNotificationDateInterpretation:
      //       UILocalNotificationDateInterpretation.absoluteTime,
      //   matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      // );


    }
  }

  //시간만 설정
  tz.TZDateTime _SetTime(Time _time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(
        tz.local, now.year, now.month, now.day, _time.hour, _time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(seconds: 3));
    }

    return scheduledDate;
  }


  tz.TZDateTime _setNotiTime(Time _time) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    tz.TZDateTime scheduledDate = _SetTime(_time);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print(now.weekday);
    // for(int i = 0; i < values.length; i++){
    //   if(now.weekday <= i){
    //     if(values[now.weekday] == false){
    //       scheduledDate = scheduledDate.add(const Duration(days: 1));
    //     }
    //   }
    // }
    values.forEach((value) {
      if (values[now.weekday] == false) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    });
    print(scheduledDate);
    return scheduledDate;
  }
}
