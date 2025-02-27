import 'package:flutter/material.dart';
import 'package:talent_link/widgets/button.dart';
import 'package:talent_link/widgets/login_page.dart';
import 'package:talent_link/widgets/signup_page.dart';

class ChooseAuthPage extends StatefulWidget {
  const ChooseAuthPage({super.key});

  @override
  State<ChooseAuthPage> createState() => _ChooseAuthPageState();
}

class _ChooseAuthPageState extends State<ChooseAuthPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Spacer(flex: 5),
            Image.asset('assets/images/3.jpg', fit: BoxFit.cover),
            Spacer(flex: 2),
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
              text: "Login",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            BaseButton(
              text: "SignUp",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
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
