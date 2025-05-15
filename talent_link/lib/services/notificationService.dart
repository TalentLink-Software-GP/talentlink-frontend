import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:talent_link/models/notfificationModel.dart';

class NotificationService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api';
  late String token;

  Future<String> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'defaultUsername';
  }

  Future<List<NotificationModel>> fetchApplyForJobNotifications() async {
    try {
      final username = await getCurrentUsername();
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/getAppliedJob/$username'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load job notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching job notifications: $e');
      return [];
    }
  }

  Future<List<NotificationModel>> fetchJobNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/getGlobalJobNotification'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load job notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching job notifications: $e');
      return [];
    }
  }

  Future<List<NotificationModel>>
  fetchUserNotificationsLikeCommentReply() async {
    try {
      String username = await getCurrentUsername();
      // final username = "ahmadawwad";
      print("Fetching notifications for: $username");
      print(
        'Full URL: $_baseUrl/notifications/getPrivateNotificationsLikeCommentReply',
      );
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/notifications/getPrivateNotificationsLikeCommentReply/$username',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Notifications fetched successfully: $data");
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load job notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in _fetchNotifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications/markAsRead/$notificationId'),
      );

      if (response.statusCode == 200) {
        print('Notification marked as read');
      } else {
        print('Failed to mark as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}
