import 'package:flutter/material.dart';

class LoginSignupTextFieled extends StatelessWidget {
  final String textHint, textLable;
  const LoginSignupTextFieled({
    super.key,
    required this.textHint,
    required this.textLable,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        textAlign: TextAlign.center,
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
