import 'package:flutter/material.dart';

class BaseButton extends StatefulWidget {
  const BaseButton({super.key});

  @override
  State<BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<BaseButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () {}, child: Text("BaseButton"));
  }
}
