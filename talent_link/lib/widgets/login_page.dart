import 'package:flutter/material.dart';
import 'package:talent_link/widgets/button.dart';
import 'package:talent_link/widgets/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Spacer(flex: 4),
            Image.asset("assets/images/5.jpg", fit: BoxFit.cover),
            Spacer(flex: 3),
            Text(
              "TalentLink",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  label: Text("Username"),
                  hintText: 'Enter Username',
                  fillColor: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: 'Enter Password',
                  fillColor: Colors.white,
                  label: Text("Password"),
                ),
              ),
            ),
            TextButton(onPressed: () {}, child: Text("Forget Password?")),
            BaseButton(text: "Login", onPressed: () {}),
            BaseButton(
              text: "Dont Have an Account? Sign Up",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
            ),

            Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}
