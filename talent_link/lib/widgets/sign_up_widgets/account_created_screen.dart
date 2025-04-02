import 'package:flutter/material.dart';
import 'package:talent_link/widgets/base_widgets/button.dart';
import 'package:talent_link/widgets/login_widgets/login_page.dart';

class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Created')),
      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ensures the column takes minimal space
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 10),

            Text('Account successfully created!'),
            Spacer(flex: 1),
            BaseButton(
              text: "Login Now!",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            Spacer(flex: 10),
          ],
        ),
      ),
    );
  }
}
