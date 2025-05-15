// login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:talent_link/utils/AppLifecycleManager.dart';
import 'package:talent_link/widgets/base_widgets/button.dart';
import 'package:talent_link/widgets/after_login_pages/home_page.dart';
import 'package:talent_link/widgets/after_login_pages/organization_home_page.dart';
import 'package:talent_link/widgets/forget_account_widgets/forgot_account_screen.dart';
import 'package:talent_link/widgets/sign_up_widgets/sign_up_choose_positions.dart';
import 'package:talent_link/widgets/base_widgets/text_field.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/5.jpg", fit: BoxFit.cover),
                    Text(
                      "TalentLink",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 40,
                      ),
                    ),
                    MyTextFieled(
                      controller: emailController,
                      textHint: "Enter Email",
                      textLable: "Email",
                      obscureText: false,
                    ),
                    MyTextFieled(
                      controller: passwordController,
                      textHint: "Enter Password",
                      textLable: "Password",
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    BaseButton(
                      text: "Login",
                      onPressed: () async {
                        String email = emailController.text;
                        String password = passwordController.text;
                        var url = Uri.parse(
                          'http://10.0.2.2:5000/api/auth/login',
                        );
                        var response = await http.post(
                          url,
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "email": email,
                            "password": password,
                          }),
                        );

                        if (response.statusCode == 200) {
                          var data = jsonDecode(response.body);
                          String token = data["token"];
                          Map<String, dynamic> decodedToken = JwtDecoder.decode(
                            token,
                          );
                          String userId = decodedToken['id'];
                          String role = decodedToken['role'];
                          String username = decodedToken['username'];
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('token', token);
                          await prefs.setString('username', username);
                          await prefs.setString('role', role);

                          final manager =
                              context
                                  .findAncestorWidgetOfExactType<
                                    AppLifecycleManager
                                  >();
                          if (manager != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AppLifecycleManager(
                                      userId: userId,
                                      token: token,
                                      child:
                                          role == "Organization"
                                              ? OrganizationHomePage(
                                                token: token,
                                              )
                                              : HomePage(data: token),
                                    ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        role == "Organization"
                                            ? OrganizationHomePage(token: token)
                                            : HomePage(data: token),
                              ),
                            );
                          }
                        } else {
                          print("Login failed: ${response.body}");
                        }
                      },
                    ),
                    BaseButton(
                      text: "Don't Have an Account? Sign Up",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChoosePositions(),
                          ),
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotAccountScreen(),
                          ),
                        );
                      },
                      child: const Text("Forgot Account?"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
