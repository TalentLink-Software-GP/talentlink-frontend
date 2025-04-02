import 'package:flutter/material.dart';

class OrganizationHomePage extends StatefulWidget {
  final String data;
  const OrganizationHomePage({super.key, required this.data});

  @override
  State<OrganizationHomePage> createState() => _OrganizationHomePageState();
}

class _OrganizationHomePageState extends State<OrganizationHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Welcome To Orgnization Page ${widget.data}} ")),
    );
  }
}
