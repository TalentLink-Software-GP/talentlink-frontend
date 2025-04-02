import 'package:flutter/material.dart';
import 'package:talent_link/widgets/sign_up_widgets/account_created_screen.dart';
import 'package:talent_link/widgets/applicatin_startup/startup_page.dart';
import 'package:talent_link/widgets/sign_up_widgets/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/signup') {
          final args = settings.arguments as Map<String, String>?;

          if (args == null ||
              !args.containsKey('country') ||
              !args.containsKey('date') ||
              !args.containsKey('city') ||
              !args.containsKey('gender') ||
              !args.containsKey('role')) {
            throw ArgumentError("Missing required arguments for SignUpScreen.");
          }

          return MaterialPageRoute(
            builder:
                (context) => SignUpScreen(
                  country: args['country']!,
                  date: args['date']!,
                  city: args['city']!,
                  gender: args['gender']!,
                  userRole: args['role']!,
                ),
          );
        } else if (settings.name == '/account-created') {
          return MaterialPageRoute(
            builder: (context) => AccountCreatedScreen(),
          );
        }

        return null;
      },
      routes: {'/': (context) => const StartupPage()},
    );
  }
}
