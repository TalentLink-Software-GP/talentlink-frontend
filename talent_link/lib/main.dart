//   runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));

// main.dart
//TODO: notfication fillter
//TODO: application meeting
// TODO: like view extra

// TODO : sort notitification  time

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_link/firebase_options.dart';
import 'package:talent_link/services/fcm_service.dart';
import 'package:talent_link/utils/app_lifecycle_manager.dart';
import 'package:talent_link/utils/push_notifications_firebase.dart';
import 'package:talent_link/utils/theme/app_theme.dart';
import 'package:talent_link/widgets/after_login_pages/home_page.dart';
import 'package:talent_link/widgets/after_login_pages/organization_home_page.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tabs/job_details_screen.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/mesage_profile.dart';
import 'package:talent_link/widgets/appSetting/theremeProv.dart';
import 'package:talent_link/widgets/sign_up_widgets/account_created_screen.dart';
import 'package:talent_link/widgets/applicatin_startup/startup_page.dart';
import 'package:talent_link/widgets/sign_up_widgets/signup_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    logger.i('Notification receivedaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  }
}

Future<void> requestPermissions() async {
  await [Permission.microphone, Permission.camera].request();
}

Future<bool> validateToken(String token) async {
  // try {
  //   final response = await http.get(
  //     Uri.parse("https://your-backend.com/api/validate-token"),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // } catch (e) {
  //   return false;
  // }
  return true;
}

void main() async {
  await dotenv.load(fileName: "api.env");

  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i("Firebase initialized successfully");

    await PushNotificationsFirebase.init();
    logger.i("Push Notifications initialized");
  } catch (e) {
    logger.e("Error initializing Firebase", error: e);
  }

  FirebaseMessaging.instance.getToken().then((token) async {
    logger.i("Current FCM Token: $token");
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  final prefs = await SharedPreferences.getInstance();
  final storedToken = prefs.getString('token');
  final storedRole = prefs.getString('role');
  final storedUserId = prefs.getString('userId');
  final storedUsername = prefs.getString('username');

  bool isValidToken = false;

  if (storedToken != null && storedToken.isNotEmpty) {
    try {
      isValidToken = await validateToken(storedToken);
    } catch (e) {
      logger.e("Token validation failed: $e");
      // Clear all stored data on token validation failure
      prefs.remove('token');
      prefs.remove('role');
      prefs.remove('userId');
      prefs.remove('username');
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(
        isLoggedIn: isValidToken,
        userToken: isValidToken ? storedToken : null,
        userRole: isValidToken ? storedRole : null,
        userId: isValidToken ? storedUserId : null,
        username: isValidToken ? storedUsername : null,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? userId;
  final String? token;
  final bool isLoggedIn;
  final String? userToken;
  final String? userRole;
  final String? username;

  const MyApp({
    this.userId,
    this.token,
    super.key,
    required this.isLoggedIn,
    this.userToken,
    this.userRole,
    this.username,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    ); // <-- Add this line

    return MaterialApp(
      title: 'TalentLink',
      navigatorKey: navigatorKey,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
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
        } else if (settings.name == '/job') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (context) =>
                    JobDetailsScreen(job: args['job'], token: args['token']),
          );
        }
        return null;
      },
      routes: {
        '/':
            (context) =>
                isLoggedIn
                    ? (userRole == 'Organization'
                        ? OrganizationHomePage(token: userToken ?? '')
                        : HomePage(
                          data: userToken ?? '',
                          onTokenChanged: (String userToken) => userToken,
                        ))
                    : StartupPage(),

        // '/': (context) => const StartupPage(),
        '/chat': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as Map<String, String>;
          return ChatPage(
            currentUserId: args['currentUserId'] ?? '',
            peerUserId: args['peerUserId'] ?? '',
            peerUsername: args['peerUsername'] ?? '',
            currentuserAvatarUrl: args['currentuserAvatarUrl'] ?? '',
            token: args['token'] ?? '',
            onChatClosed: () {},
          );
        },
      },
    );
  }
}
