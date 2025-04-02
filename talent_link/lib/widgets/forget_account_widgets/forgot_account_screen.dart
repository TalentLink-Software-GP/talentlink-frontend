// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:talent_link/widgets/forget_account_widgets/enter_reset_code_screen.dart';

class ForgotAccountScreen extends StatefulWidget {
  const ForgotAccountScreen({super.key});

  @override
  _ForgotAccountScreenState createState() => _ForgotAccountScreenState();
}

class _ForgotAccountScreenState extends State<ForgotAccountScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendResetLink() async {
    final String apiUrl = "http://10.0.2.2:5000/api/auth/forgot-password";
    final String email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your email")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData["message"])));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"] ?? "Error occurred")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to the server")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Account")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter your email to reset your password",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: "Enter your email",
                  label: const Text("Email"),
                  labelStyle: const TextStyle(color: Colors.black),
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () {
                          sendResetLink();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EnterResetCodeScreen(
                                    email: emailController.text,
                                  ),
                            ),
                          );
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C9E91),
                  foregroundColor: Colors.white,
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Send Reset Link"),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Back to Login",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
