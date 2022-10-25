

import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarController extends GetxController{
  Rx<DateTime> selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).obs;
  Rx<CalendarFormat> calendarFormat = CalendarFormat.month.obs;

  Rx<DateTime> focusedDay = DateTime.now().obs;
  // DateTime focusedDay2 = DateTime.now();

  selected(selectedDay2, focusedDay2){
    this.selectedDay.value = selectedDay2;
    this.focusedDay.value = focusedDay2;
    update();
  }

  focus(){
    this.focusedDay = focusedDay;
  }

  @override
  void onInit() {
    super.onInit();
  }
}