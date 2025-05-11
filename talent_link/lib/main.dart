//   runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));

// main.dart
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_link/firebase_options.dart';
import 'package:talent_link/services/FCMService.dart';
import 'package:talent_link/utils/AppLifecycleManager.dart';
import 'package:talent_link/utils/push_notifications_firebase.dart';
import 'package:talent_link/widgets/sign_up_widgets/account_created_screen.dart';
import 'package:talent_link/widgets/applicatin_startup/startup_page.dart';
import 'package:talent_link/widgets/sign_up_widgets/signup_page.dart';

//function to listen backkground changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print('notification recived');
  }
}

void main() async {
  // Ensure Flutter is initialized properly
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
    await _handleFcmRecovery();

    await PushNotificationsFirebase.init();
    print("✅ Push Notifications initialized");
  } catch (e) {
    print("❌ Error initializing Firebase: $e");
  }
  FirebaseMessaging.instance.getToken().then((token) {
    print("Current FCM Token: $token");
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  runApp(const MyApp());
}

Future<void> _handleFcmRecovery() async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      final fcmService = FCMService();
      await fcmService.nuclearReset();
    }
  } catch (e) {
    print('FCM recovery failed: $e');
  }
} //ctKXRrQNQTawKEfxv2uTY6:APA91bHJu2lh2Vwg1v9pqMyHXwCL56wc9he_yo1M0OUoyuxzjZQ8GCcQmW2Bwv-Z5NMCliet1ng9IEzscUEAJ0HjdRGkWjXQzkmug3n_6pLF2FEnMwoXgww
//ctKXRrQNQTawKEfxv2uTY6:APA91bE7NbTQUez77ppdSAHeUSPYrG984imH8RUKowHrFbKLAEZOcgYLD7vrSruTDoVAPzY0E_PsXLjsYxpSL5QL4GJgov5n0Gl4iUysDlNZ59UAE5-3mnY
//
//

class MyApp extends StatelessWidget {
  final String? userId;
  final String? token;

  const MyApp({this.userId, this.token, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C9E91)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      builder: (context, child) {
        return AppLifecycleManager(userId: null, token: null, child: child!);
      },
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
