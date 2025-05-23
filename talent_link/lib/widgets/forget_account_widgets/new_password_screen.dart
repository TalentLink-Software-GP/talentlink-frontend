// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:talent_link/widgets/base_widgets/button.dart';
import 'package:talent_link/widgets/base_widgets/text_field.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;

  const NewPasswordScreen({super.key, required this.email});

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void resetPassword() async {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    final response = await http.post(
      Uri.parse(
        '${const String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:5000/api')}/auth/set-new-password',
      ),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'email': widget.email,
        'password': password,
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.statusCode == 200
              ? "Password reset successfully"
              : "Failed to reset password",
        ),
      ),
    );

    if (response.statusCode == 200) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set New Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            MyTextFieled(
              textHint: "Enter new password",
              textLable: "New Password",
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            MyTextFieled(
              textHint: "Confirm password",
              textLable: "Confirm Password",
              controller: confirmPasswordController,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            BaseButton(text: "Reset Password", onPressed: resetPassword),
          ],
        ),
      ),
    );
  }
}
