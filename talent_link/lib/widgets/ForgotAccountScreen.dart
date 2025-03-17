import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotAccountScreen extends StatefulWidget {
  const ForgotAccountScreen({super.key});

  @override
  _ForgotAccountScreenState createState() => _ForgotAccountScreenState();
}

class _ForgotAccountScreenState extends State<ForgotAccountScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendResetLink() async {
    //  var url = Uri.parse(
    //   'http://10.0.2.2:5000/api/auth/verify-email/${widget.token}',
    // );
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  isLoading
                      ? null
                      : () {
                        sendResetLink(); // Call your existing function
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
              child:
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Send Reset Link"),
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

//////////////////////////////////////////////////////////////////////////////next page
///
///
///

class EnterResetCodeScreen extends StatefulWidget {
  final String email;

  const EnterResetCodeScreen({super.key, required this.email});

  @override
  _EnterResetCodeScreenState createState() => _EnterResetCodeScreenState();
}

class _EnterResetCodeScreenState extends State<EnterResetCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  Future<void> verifyResetCode() async {
    final String apiUrl =
        "http://10.0.2.2:5000/api/auth/verify-reset-code"; // Replace with your backend URL
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
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Reset Code",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : verifyResetCode,
              child:
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Verify Code"),
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////next page

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
      Uri.parse('http://10.0.2.2:5000/api/auth/set-new-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email, // Use widget.email here
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successfully")),
      );
      Navigator.popUntil(context, (route) => route.isFirst); // Go back to login
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to reset password")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set New Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter your new password",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPassword,
              child: const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
