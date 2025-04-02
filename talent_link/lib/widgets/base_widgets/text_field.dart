import 'package:flutter/material.dart';

class MyTextFieled extends StatelessWidget {
  final String textHint, textLable;
  final TextEditingController controller;
  final bool obscureText;
  const MyTextFieled({
    super.key,
    required this.textHint,
    required this.textLable,
    required this.controller,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: textHint,
          fillColor: Colors.white,
          label: Text(textLable),
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
