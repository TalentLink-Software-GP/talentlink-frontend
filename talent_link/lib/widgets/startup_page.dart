import 'package:flutter/material.dart';
import 'package:talent_link/widgets/button.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(flex: 4),
        Image.asset(
          'assets/images/3.jpg',
          fit: BoxFit.cover, // or BoxFit.contain
        ),
        Spacer(flex: 3),
        Text(
          "TalentLink",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "TalentLink is a platform designed to connect talented individuals with opportunities, providing a streamlined way for both job seekers and employers to engage, discover, and collaborate on projects or positions.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ),
        Spacer(flex: 1),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 24.0),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0C9E91),
              foregroundColor: Colors.white,
            ),
            child: Text("Get Started"),
          ),
        ),
        Spacer(flex: 1),
      ],
    );
  }
}
