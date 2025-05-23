import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_link/widgets/applicatin_startup/startup_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class LogoutButton extends StatelessWidget {
  LogoutButton({super.key});

  final _logger = Logger();
  final String baseUrl = dotenv.env['BASE_URL']!;

  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');
      final role = prefs.getString('role');

      if (token != null && userId != null) {
        // Get current FCM token
        final fcmToken = await FirebaseMessaging.instance.getToken();

        if (fcmToken != null) {
          // Call API to remove this FCM token
          await _removeUserFcmToken(userId, fcmToken, token, role ?? 'User');
        }
      }

      // Delete FCM token from Firebase
      await FirebaseMessaging.instance.deleteToken();

      // Clear preferences
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('username');
      await prefs.remove('role');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StartupPage()),
          (route) => false,
        );
      }
    } catch (e) {
      _logger.e('Error during logout', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout completed with some errors')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StartupPage()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _removeUserFcmToken(
    String userId,
    String fcmToken,
    String authToken,
    String role,
  ) async {
    try {
      final endpoint =
          role == 'Organization'
              ? '$baseUrl/organization/remove-fcm-token'
              : '$baseUrl/users/remove-fcm-token';

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'id': userId, 'fcmToken': fcmToken}),
      );

      if (response.statusCode != 200) {
        _logger.e('Failed to remove FCM token: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error removing FCM token', error: e);
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                logout(context); // Proceed with logout
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Color.fromARGB(255, 10, 10, 10)),
      title: const Text(
        'Logout',
        style: TextStyle(color: Color.fromARGB(255, 20, 20, 20)),
      ),
      onTap: () => _showLogoutConfirmationDialog(context),
    );
  }
}
