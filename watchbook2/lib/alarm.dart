import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

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
  int? _hour;
  int? _minute;
  Time? _time;
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
    }

    return 'failed';
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
            RaisedButton(
              child: const Text('적용'),
              onPressed: _dailyAtTimeNotification,
            ),
            RaisedButton(
              onPressed: () {
                _show();
              },
              child: const Text('알람시간 선택'),
            ),
            Text('설정한시간 : $_selectedTime'),
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

    if (result == null) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.deleteNotificationChannelGroup('id');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        1, // id는 unique해야합니다. int값
        notiTitle,
        notiDesc,
        _setNotiTime(_time!),
        detail,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  tz.TZDateTime _setNotiTime(Time _time) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, _time.hour, _time.minute);
    print(scheduledDate);
    scheduledDate = scheduledDate.add(const Duration(days: 1));
    if (scheduledDate.isBefore(now)) {
      scheduledDate =
          tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3));
    }
    return scheduledDate;
  }
}
