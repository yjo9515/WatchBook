import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import '../controller/member_controller.dart';

class history_view extends GetView<MemberController>{
  @override
  Widget build(BuildContext context) {
    return Text('출입 기록');
  }

}