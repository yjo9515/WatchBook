import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class H1 extends StatelessWidget {
  String changeValue = '';

  String hintText = '';
  H1({
    required this.changeValue,
  });
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Text(
      changeValue,
      textAlign: TextAlign.left,
      style: TextStyle(
          fontSize: 20,
          color: Color.fromARGB(255, 18, 136, 248)
      ),
    );
  }
}