import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:talent_link/widgets/sign_up_widgets/account_created_screen.dart';

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
