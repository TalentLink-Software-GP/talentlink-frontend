import 'package:flutter/material.dart';

class MessageNotification extends StatelessWidget {
  final int count;

  const MessageNotification({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final int countTest = 5;
    // count = countTest;
    return countTest > 0
        ? Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$countTest',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        )
        : SizedBox();
  }
}
