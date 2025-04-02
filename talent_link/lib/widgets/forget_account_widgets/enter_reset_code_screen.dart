// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:talent_link/widgets/forget_account_widgets/new_password_screen.dart';

class EnterResetCodeScreen extends StatefulWidget {
  final String email;

  const EnterResetCodeScreen({super.key, required this.email});

  @override
  _EnterResetCodeScreenState createState() => _EnterResetCodeScreenState();
}

class _EnterResetCodeScreenState extends State<EnterResetCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyResetCode() async {
    final String apiUrl = "http://10.0.2.2:5000/api/auth/verify-reset-code";
    final String resetCode = codeController.text.trim();

    if (resetCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the reset code")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email, "resetCode": resetCode}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData["message"])));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordScreen(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData["message"] ?? "Invalid reset code"),
          ),
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
      appBar: AppBar(title: const Text("Enter Reset Code")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Enter the code sent to your email",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: "Enter reset code",
                  label: const Text("Reset Code"),
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
                onPressed: isLoading ? null : verifyResetCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C9E91),
                  foregroundColor: Colors.white,
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Verify Code"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
