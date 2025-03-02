import 'package:flutter/material.dart';
import 'package:talent_link/widgets/button.dart';
import 'package:talent_link/widgets/login_page.dart';
import 'package:talent_link/widgets/text_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Image.asset("assets/images/5.jpg", fit: BoxFit.cover),
            Text(
              "TalentLink",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40),
            ),
            LoginSignupTextFieled(
              textHint: "Enter Username",
              textLable: "Username",
            ),
            LoginSignupTextFieled(textHint: "Enter Email", textLable: "Email"),
            LoginSignupTextFieled(
              textHint: "Enter Phone Number",
              textLable: "Phone Number",
            ),
            LoginSignupTextFieled(
              textHint: "Choose Password",
              textLable: "Password",
            ),
            LoginSignupTextFieled(
              textHint: "Enter Password Again",
              textLable: "Password",
            ),
            BaseButton(text: "SigneUp", onPressed: () {}),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text("ALready have an account? Try Login"),
            ),
          ],
        ),
      ),
    );
  }
}
