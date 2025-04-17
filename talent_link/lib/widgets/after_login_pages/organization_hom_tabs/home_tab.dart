import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  final String token;
  const HomeTab({super.key, required this.token});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(children: [Text("Home Tab")]));
  }
}
