import 'package:flutter/material.dart';
import 'package:talent_link/widgets/button.dart';
import 'package:talent_link/widgets/login_page.dart';
import 'package:talent_link/widgets/sign_up_choose_positions.dart';

import 'package:talent_link/widgets/ForgotAccountScreen.dart';

class ChooseAuthPage extends StatefulWidget {
  const ChooseAuthPage({super.key});

  @override
  State<ChooseAuthPage> createState() => _ChooseAuthPageState();
}

class _ChooseAuthPageState extends State<ChooseAuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        // Allow scrolling
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50), // Adjust spacing
            Image.asset('assets/images/3.jpg', fit: BoxFit.cover),
            const SizedBox(height: 20),
            const Text(
              "TalentLink",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                "TalentLink is a platform designed to connect talented individuals with opportunities, providing a streamlined way for both job seekers and employers to engage, discover, and collaborate on projects or positions.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
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
                  MaterialPageRoute(builder: (context) => ChoosePositions()),
                );
              },
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotAccountScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Forgot Account?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
