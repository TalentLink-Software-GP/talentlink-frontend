import 'package:flutter/material.dart';
import 'package:talent_link/widgets/button.dart';
import 'package:talent_link/widgets/home_page.dart';
import 'package:talent_link/widgets/organization_home_page.dart';
import 'package:talent_link/widgets/sign_up_choose_positions.dart';

import 'package:talent_link/widgets/text_field.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text(
              "TalentLink",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40),
            ),
            LoginSignupTextFieled(
              controller: emailController,
              textHint: "Enter Email",
              textLable: "Email",
              obscureText: false,
            ),
            LoginSignupTextFieled(
              controller: passwordController,
              textHint: "Enter Password",
              textLable: "Password",
              obscureText: true,
            ),
            BaseButton(
              text: "Login",
              onPressed: () async {
                String email = emailController.text;
                String password = passwordController.text;
                var url = Uri.parse('http://10.0.2.2:5000/api/auth/login');
                var response = await http.post(
                  url,
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({"email": email, "password": password}),
                );

                if (response.statusCode == 200) {
                  var data = jsonDecode(response.body);
                  String token = data["token"];
                  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
                  String userRole = decodedToken['role'];
                  if (userRole == "Organization") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrganizationHomePage(data: token),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => HomePage(
                              data: token, // Pass formatted data
                            ),
                      ),
                    );
                  }
                } else {
                  // ignore: avoid_print
                  print("Login failed: ${response.body}");
                }
              },
            ),
            BaseButton(
              text: "Dont Have an Account? Sign Up",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChoosePositions()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
