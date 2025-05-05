import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchPageService {
  final String baseUrl = 'http://10.0.2.2:5000/api';

  Future<List<dynamic>> fetchChatHistory(String currentUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat-history/$currentUserId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> fetchedHistory = json.decode(response.body);

        fetchedHistory.sort((a, b) {
          DateTime timeA = DateTime.parse(a['lastMessageTimestamp']);
          DateTime timeB = DateTime.parse(b['lastMessageTimestamp']);
          return timeB.compareTo(timeA);
        });

        return fetchedHistory;
      } else {
        print(
          'Failed to fetch chat history. Status code: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Error fetching chat history: $e');
      return [];
    }
  }

  Future<List<dynamic>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?q=$query'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
          'Failed to fetch search results. Status code: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Future<bool> deleteChatHistory(String currentUserId, String userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/delete-message/$currentUserId/$userId'),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error hiding chat: $e');
      return false;
    }
  }

  Future<int> fetchUnreadMessageCount(String currentUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/unread-count/$currentUserId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unreadCount'] ?? 0;
      } else {
        print(
          'Failed to fetch unread message count. Status code: ${response.statusCode}',
        );
        return 0;
      }
    } catch (e) {
      print('Error fetching unread message count: $e');
      return 0;
    }
  }
}
