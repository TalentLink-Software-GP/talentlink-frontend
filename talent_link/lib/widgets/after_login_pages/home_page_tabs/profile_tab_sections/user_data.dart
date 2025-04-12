import 'package:flutter/material.dart';

class UserData extends StatelessWidget {
  const UserData({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Icon(Icons.location_on),
            SizedBox(width: 8),
            Text('Location'),
          ],
        ),
        Row(children: [Icon(Icons.work), SizedBox(width: 8), Text('Hired')]),
        Row(
          children: [
            Icon(Icons.group),
            SizedBox(width: 8),
            Text('Connections'),
          ],
        ),
      ],
    );
  }
}
