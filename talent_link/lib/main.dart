import 'package:flutter/material.dart';
import 'package:talent_link/widgets/startup_page.dart';
import 'package:talent_link/widgets/signup_page.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       initialRoute: '/', // Start from StartupPage
//       routes: {
//         '/': (context) => const StartupPage(),
//         '/signup': (context) => const SignUpScreen(),
//         // '/verify-email': (context) => const VerifyEmailScreen(),
//         '/account-created': (context) => const AccountCreatedScreen(),
//       },
//     );
//   }
// }

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       initialRoute: '/', // Start from StartupPage

//       routes: {
//         '/': (context) => const StartupPage(),
//         '/signup': (context) => const SignUpScreen(),
//       },

//       onGenerateRoute: (settings) {
//         // Handle custom routes here
//         if (settings.name == '/account-created') {
//           final String token =
//               settings.arguments as String; // Extract token from arguments
//           return MaterialPageRoute(
//             builder: (context) => AccountCreatedScreen(token: token),
//           );
//         }
//         return null; // Return null for other routes, or define more custom routes if needed
//       },
//     );
//   }
// }

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const StartupPage(),

        '/signup': (context) => const SignUpScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/account-created') {
          final token = Uri.parse(settings.name!).queryParameters['token'];
          return MaterialPageRoute(
            builder: (context) => AccountCreatedScreen(token: token!),
          );
        }
        return null;
      },
    );
  }
}
