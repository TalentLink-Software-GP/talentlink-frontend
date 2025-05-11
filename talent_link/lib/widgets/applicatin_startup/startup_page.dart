import 'package:flutter/material.dart';
import 'package:talent_link/widgets/base_widgets/button.dart';
import 'package:talent_link/widgets/applicatin_startup/choose_auth_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});
  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Spacer(flex: 4),
            Image.asset('assets/images/3.jpg', fit: BoxFit.cover),
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
            BaseButton(
              text: "Get Started",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChooseAuthPage()),
                );
              },
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
