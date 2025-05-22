//new api all fixed i used api.env

import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final String baseUrl = dotenv.env['BASE_URL']!;

class FCMService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final _logger = Logger();

  /// Nuclear reset for FCM tokens
  Future<void> nuclearReset() async {
    _logger.i('💣 Initiating FCM nuclear reset...');

    // 1. Force unregister
    await _fcm.deleteToken();

    // 2. Clear cached FCM data
    await Firebase.app().delete();
    await Firebase.initializeApp();

    // 3. Get fresh token
    String? newToken = await _fcm.getToken();
    _logger.i('💥 NEW TOKEN: $newToken');

    // 4. Validate token
    if (newToken == null || !newToken.startsWith('APA')) {
      throw Exception('Invalid token generated');
    }

    // 5. Send to backend
    await _sendTokenToServer(newToken);
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        // Send to token backend API
        final response = await http.post(
          //192.168.1.7     Uri.parse('http://10.0.2.2:5000/api/users/save-fcm-token'),
          Uri.parse('$baseUrl/users/save-fcm-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'fcmToken': token}),
        );

        if (response.statusCode == 200) {
          _logger.i('Token successfully saved on server');
        } else {
          _logger.e('Failed to save token on server');
        }
      }
    } catch (e) {
      _logger.e('Error sending token to server:', error: e);
    }
  }
}
