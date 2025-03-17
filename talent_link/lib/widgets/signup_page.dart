import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

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
  final _formKey = GlobalKey<FormState>();

  bool agreeToTerms = false;
  bool _obscurePassword = true;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
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
      String userEmail = email;

      if (response.statusCode == 201) {
        var data = jsonDecode(response.body);
        print("🔍 Full API Response: ${response.body}");

        if (data.containsKey("token")) {
          String realToken = data["token"];

          print("token: $realToken");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CheckVerificationScreen(
                    token: realToken,
                    email: userEmail,
                  ),
            ),
          );
        } else {
          print("❌ Token not received: ${response.body}");
        }
      } else {
        print("❌ Sign-up failed: ${response.body}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Let's create your account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      Icons.person,
                      "First Name",
                      controller: firstNameController,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      Icons.person,
                      "Last Name",
                      controller: lastNameController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildTextField(
                Icons.person_outline,
                "Username",
                controller: usernameController,
              ),
              SizedBox(height: 10),
              _buildTextField(
                Icons.email,
                "E-Mail",
                controller: emailController,
                isEmail: true,
              ),
              SizedBox(height: 10),
              _buildTextField(
                Icons.phone,
                "Phone Number",
                controller: phoneController,
                isPhone: true,
              ),
              SizedBox(height: 10),
              _buildPasswordField(),
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (agreeToTerms) {
                    registerUser();
                  } else {
                    print("❌ You must agree to the terms and conditions.");
                  }
                },
                child: Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hintText, {
    bool obscureText = false,
    TextEditingController? controller,
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType:
          isEmail
              ? TextInputType.emailAddress
              : isPhone
              ? TextInputType.phone
              : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.black54,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hintText cannot be empty";
        }
        if (isEmail &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return "Enter a valid email";
        }
        if (isPhone && !RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
          return "Enter a valid phone number";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        hintText: "Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.black54,
        suffixIcon: GestureDetector(
          onTapDown: (_) {
            setState(() {
              _obscurePassword = false;
            });
          },
          onTapUp: (_) {
            setState(() {
              _obscurePassword = true;
            });
          },
          child: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password cannot be empty";
        }
        if (value.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
    );
  }
}

class CheckVerificationScreen extends StatefulWidget {
  final String token;
  final String email;

  const CheckVerificationScreen({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  _CheckVerificationScreenState createState() =>
      _CheckVerificationScreenState();
}

class _CheckVerificationScreenState extends State<CheckVerificationScreen> {
  late Timer timer;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      Duration(seconds: 3),
      (timer) => checkVerification(),
    );
  }

  Future<void> checkVerification() async {
    var url = Uri.parse(
      'http://10.0.2.2:5000/api/auth/isVerified/${widget.email}',
    );

    try {
      print(widget.email);
      var response = await http.get(url);
      print(response.statusCode);

      if (response.statusCode == 200) {
        setState(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AccountCreatedScreen()),
          );
        });
        timer.cancel();
        print("✅ Email verified successfully!");
        print(widget.token);
      } else {
        print("❌ Verification failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error checking verification: $e");
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            isVerified
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Verified!"),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountCreatedScreen(),
                          ),
                        );
                      },
                      child: Text("Proceed to Account Created Screen"),
                    ),
                  ],
                )
                : Text("Waiting for verification..."),
      ),
    );
  }
}

class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Created')),
      body: Center(child: Text('Account successfully created! Token: ')),
    );
  }
}
