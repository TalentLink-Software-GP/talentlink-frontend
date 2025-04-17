import 'package:flutter/material.dart';

class ApplicationsTab extends StatefulWidget {
  final String token;
  const ApplicationsTab({super.key, required this.token});

  @override
  State<ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<ApplicationsTab> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(children: [Text("Application Tab")]));
  }
}
