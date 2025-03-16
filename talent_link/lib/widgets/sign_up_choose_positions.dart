import 'package:flutter/material.dart';
import 'package:talent_link/widgets/button.dart';
import 'package:talent_link/widgets/login_page.dart';
import 'package:talent_link/widgets/signup_page.dart';
import 'package:talent_link/widgets/signup_userDetails.dart';

class ChoosePositions extends StatefulWidget {
  const ChoosePositions({super.key});

  @override
  ChoosePositionsScreen createState() => ChoosePositionsScreen();
}

class ChoosePositionsScreen extends State<ChoosePositions> {
  String selectedRole = 'Job Seeker';
  List<String> roles = ['Job Seeker', 'Freelancer', 'Organization'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create account and enjoy endless opportunities.',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'User Role',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            DropdownButtonFormField(
              value: selectedRole,
              items:
                  roles.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            BaseButton(
              text: "Next",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserDetailsScreen()),
                );
              },
            ),
            const SizedBox(height: 10.0),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text(
                  'Already Registered? Sign in now',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
