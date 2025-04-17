import 'package:flutter/material.dart';

class MyJobsTab extends StatefulWidget {
  final String token;
  const MyJobsTab({super.key, required this.token});

  @override
  State<MyJobsTab> createState() => _MyJobsTabState();
}

class _MyJobsTabState extends State<MyJobsTab> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(children: [Text("My Jobs Tab")]));
  }
}
