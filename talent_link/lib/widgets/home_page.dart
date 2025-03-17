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
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF0C9E91),
        child: Row(
          children: [
            ElevatedButton(onPressed: () {}, child: Text("Home")),
            ElevatedButton(onPressed: () {}, child: Text("Home")),
            ElevatedButton(onPressed: () {}, child: Text("Home")),
            ElevatedButton(onPressed: () {}, child: Text("Home")),
          ],
        ),
      ),
    );
  }
}
