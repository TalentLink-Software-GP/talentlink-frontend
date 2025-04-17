import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:talent_link/widgets/base_widgets/button.dart';
import 'package:talent_link/widgets/base_widgets/text_field.dart';
import 'package:talent_link/widgets/sign_up_widgets/check_verification_screen.dart';

class OrganizationSignupScreen extends StatefulWidget {
  const OrganizationSignupScreen({super.key});

  @override
  State<OrganizationSignupScreen> createState() =>
      _OrganizationSignupScreenState();
}

class _OrganizationSignupScreenState extends State<OrganizationSignupScreen> {
  // Controllers
  final TextEditingController organizationNameController =
      TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> signupOrganization() async {
    final name = organizationNameController.text.trim();
    final industry = industryController.text.trim();
    final website = websiteController.text.trim();
    final country = countryController.text.trim();
    final city = cityController.text.trim();
    final address1 = address1Controller.text.trim();
    final address2 = address2Controller.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() {
        errorMessage = "Passwords do not match.";
      });
      return;
    }

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        country.isEmpty ||
        city.isEmpty ||
        industry.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all required fields.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse(
        'http://10.0.2.2:5000/api/auth/register',
      ); // Replace this with your real URL
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "industry": industry,
          "website": website,
          "country": country,
          "city": city,
          "address1": address1,
          "address2": address2,
          "email": email,
          "password": password,
          "role": "Organization",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Organization Details")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Text("Enter Organization Details"),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: MyTextFieled(
                        textHint: "Enter Your Organization Name",
                        textLable: "Organization Name",
                        controller: organizationNameController,
                        obscureText: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: MyTextFieled(
                        textHint: "What Industry Describes Your Company?",
                        textLable: "Industry",
                        controller: industryController,
                        obscureText: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: MyTextFieled(
                        textHint: "Enter Your Website URL",
                        textLable: "Website URL",
                        controller: websiteController,
                        obscureText: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: MyTextFieled(
                        textHint: "Choose Country",
                        textLable: "Country",
                        controller: countryController,
                        obscureText: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: MyTextFieled(
                        textHint: "Choose City",
                        textLable: "City",
                        controller: cityController,
                        obscureText: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: MyTextFieled(
                        textHint: "Enter Address 1",
                        textLable: "Address 1",
                        controller: address1Controller,
                        obscureText: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: MyTextFieled(
                        textHint: "Enter Address 2 (optional)",
                        textLable: "Address 2 (optional)",
                        controller: address2Controller,
                        obscureText: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: MyTextFieled(
                        textHint: "Official Email",
                        textLable: "Official Email",
                        controller: emailController,
                        obscureText: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: MyTextFieled(
                        textHint: "Password",
                        textLable: "Password",
                        controller: passwordController,
                        obscureText: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: MyTextFieled(
                        textHint: "Re-Enter Password",
                        textLable: "Confirm Password",
                        controller: confirmPasswordController,
                        obscureText: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 64),
                      child:
                          isLoading
                              ? const CircularProgressIndicator()
                              : BaseButton(
                                text: "Submit",
                                onPressed: signupOrganization,
                              ),
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
