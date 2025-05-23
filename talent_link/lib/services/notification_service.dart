import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:talent_link/models/notfification_model.dart';
import 'package:logger/logger.dart';

class NotificationService {
  static String get _baseUrl => const String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );
  late String token;
  final _logger = Logger();

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
      _logger.e('Error fetching job notifications:', error: e);
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
      _logger.e('Error fetching job notifications:', error: e);
      return [];
    }
  }

  Future<List<NotificationModel>>
  fetchUserNotificationsLikeCommentReply() async {
    try {
      String username = await getCurrentUsername();
      _logger.i('Fetching notifications for: $username');
      _logger.i(
        'Full URL: $_baseUrl/notifications/getPrivateNotificationsLikeCommentReply',
      );

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/notifications/getPrivateNotificationsLikeCommentReply/$username',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _logger.i('Notifications fetched successfully:', error: data);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load job notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('Error in _fetchNotifications:', error: e);
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications/markAsRead/$notificationId'),
      );

      if (response.statusCode == 200) {
        _logger.i('Notification marked as read');
      } else {
        _logger.w('Failed to mark as read:', error: response.statusCode);
      }
    } catch (e) {
      _logger.e('Error marking notification as read:', error: e);
    }
  }
}
