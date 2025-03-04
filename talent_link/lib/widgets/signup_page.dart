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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
              controller: emailController,
              textHint: "Enter Username",
              textLable: "Username",
              obscureText: false,
            ),
            LoginSignupTextFieled(
              textHint: "Enter Email",
              textLable: "Email",
              controller: emailController,
              obscureText: false,
            ),
            LoginSignupTextFieled(
              controller: emailController,
              textHint: "Enter Phone Number",
              textLable: "Phone Number",
              obscureText: false,
            ),
            LoginSignupTextFieled(
              controller: emailController,
              textHint: "Choose Password",
              textLable: "Password",
              obscureText: false,
            ),
            LoginSignupTextFieled(
              controller: emailController,
              textHint: "Enter Password Again",
              textLable: "Password",
              obscureText: false,
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
