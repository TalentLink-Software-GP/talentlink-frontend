import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String data;
  const HomePage({super.key, required this.data});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("User Logged n ${widget.data}"), // ✅ No 'const' here
        ),
      ),
    );
  }
}
