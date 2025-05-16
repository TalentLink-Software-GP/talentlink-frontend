//   runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));

// main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:talent_link/firebase_options.dart';
import 'package:talent_link/services/fcm_service.dart';
import 'package:talent_link/utils/app_lifecycle_manager.dart';
import 'package:talent_link/utils/push_notifications_firebase.dart';
import 'package:talent_link/utils/theme/app_theme.dart';
import 'package:talent_link/widgets/sign_up_widgets/account_created_screen.dart';
import 'package:talent_link/widgets/applicatin_startup/startup_page.dart';
import 'package:talent_link/widgets/sign_up_widgets/signup_page.dart';

final logger = Logger();

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    logger.i('Notification received');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i("Firebase initialized successfully");
    await _handleFcmRecovery();

    await PushNotificationsFirebase.init();
    logger.i("Push Notifications initialized");
  } catch (e) {
    logger.e("Error initializing Firebase", error: e);
  }

  FirebaseMessaging.instance.getToken().then((token) {
    logger.i("Current FCM Token: $token");
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
    logger.e('FCM recovery failed', error: e);
  }
}

class MyApp extends StatelessWidget {
  final String? userId;
  final String? token;

  const MyApp({this.userId, this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalentLink',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: AppLifecycleManager(
            userId: userId,
            token: token,
            child: child!,
          ),
        );
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
