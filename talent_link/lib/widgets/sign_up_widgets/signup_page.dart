// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:talent_link/widgets/base_widgets/button.dart';
import 'package:talent_link/widgets/base_widgets/text_field.dart';
import 'package:talent_link/widgets/sign_up_widgets/check_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  final String country;
  final String date;
  final String city;
  final String gender;
  final String userRole;

  const SignUpScreen({
    super.key,
    required this.country,
    required this.date,
    required this.city,
    required this.gender,
    required this.userRole,
  });

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? errorMessage;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool agreeToTerms = false;
  final bool _obscurePassword = true;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void registerUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      String firstName = firstNameController.text;
      String lastName = lastNameController.text;
      String email = emailController.text;
      String username = usernameController.text;
      String phone = phoneController.text;
      String password = passwordController.text;
      String usercountry = widget.country;
      String userDate = widget.date;
      String userCity = widget.city;
      String userGender = widget.gender;
      String userRole = widget.userRole;

      try {
        var url = Uri.parse('http://10.0.2.2:5000/api/auth/register');

        var response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": "$firstName $lastName",
            "username": username,
            "email": email,
            "phone": phone,
            "password": password,
            "role": userRole,
            "date": userDate,
            "country": usercountry,
            "city": userCity,
            "gender": userGender,
          }),
        );

        if (response.statusCode == 201) {
          var data = jsonDecode(response.body);
          print("🔍 Full API Response: ${response.body}");

          if (data.containsKey("token")) {
            String realToken = data["token"];

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        CheckVerificationScreen(token: realToken, email: email),
              ),
            );
          } else {
            print("❌ Token not received: ${response.body}");
          }
        } else {
          print("❌ Sign-up failed: ${response.body}");
        }
      } catch (e) {
        setState(() {
          errorMessage = "An error occurred. Please try again.";
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/5.jpg", fit: BoxFit.cover),
                    Text(
                      "Let's create your account",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: MyTextFieled(
                            textHint: "Enter first name",
                            textLable: "First Name",
                            controller: firstNameController,
                            obscureText: false,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MyTextFieled(
                            textHint: "Enter last name",
                            textLable: "Last Name",
                            controller: lastNameController,
                            obscureText: false,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    MyTextFieled(
                      textHint: "Enter your username",
                      textLable: "Username",
                      controller: usernameController,
                      obscureText: false,
                    ),
                    SizedBox(height: 10),
                    MyTextFieled(
                      textHint: "Enter your email",
                      textLable: "E-Mail",
                      controller: emailController,
                      obscureText: false,
                    ),
                    SizedBox(height: 10),
                    MyTextFieled(
                      textHint: "Enter your phone number",
                      textLable: "Phone Number",
                      controller: phoneController,
                      obscureText: false,
                    ),
                    SizedBox(height: 10),
                    MyTextFieled(
                      textHint: "Enter your password",
                      textLable: "Password",
                      controller: passwordController,
                      obscureText: _obscurePassword,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          onChanged: (bool? value) {
                            setState(() {
                              agreeToTerms = value ?? false;
                            });
                          },
                        ),
                        Text("I agree to "),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            "Privacy Policy",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        Text(" and "),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            "Terms of use",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    BaseButton(
                      text: "Create Account",
                      onPressed: () {
                        if (agreeToTerms) {
                          registerUser();
                        } else {
                          print(
                            "❌ You must agree to the terms and conditions.",
                          );
                        }
                      },
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
