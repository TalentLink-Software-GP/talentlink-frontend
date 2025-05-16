import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/mesageProfile.dart';

class MessageService {
  final String token;
  final String baseUrl = 'http://10.0.2.2:5000/api';

  MessageService(this.token);

  Future<Map<String, dynamic>?> getUserId() async {
    final decodedToken = JwtDecoder.decode(token);
    final role = decodedToken['role'];
    final username = decodedToken['username'];
    //IM HERE
    String userApiUrl;
    if (role == 'Job Seeker' || role == 'Freelancer') {
      userApiUrl = 'http://10.0.2.2:5000/api/users/get-user-id';
    } else if (role == 'Organization') {
      userApiUrl =
          '$baseUrl/organization/getOrgDataWithuserName?userName=${Uri.encodeComponent(username)}';
      //        '$baseUrl/organization/getOrgDataWithuserName?userName=${Uri.encodeComponent(username)}',
    } else {
      debugPrint("no role !!!!: $role");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(userApiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return {
          'userId': userData['userId'],
          'avatarUrl': userData['avatarUrl'],
        };
      } else {
        debugPrint("Failed to fetch user ID: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user ID: $e");
      return null;
    }
  }

  Future<void> navigateToSearchPage(BuildContext context) async {
    final userInfo = await getUserId(); // Now returns a Map

    if (userInfo != null && userInfo['userId'] != null) {
      print(userInfo['userId']);
      print(userInfo['avatarUrl']);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => SearchUserPage(
                currentUserId: userInfo['userId'],
                avatarUrl: userInfo['avatarUrl'],
                token: token,
              ),
        ),
      );
    }
  }
}

class MessageService2 {
  final String baseUrl = 'http://10.0.2.2:5000/api';

  Future<Map<String, dynamic>?> fetchPeerInfo(String username) async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/getUserData?userName=$username'),
    );
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchMessages(
    String currentUserId,
    String peerUserId,
  ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/messages/$currentUserId/$peerUserId'),
    );
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(res.body));
    }
    return [];
  }

  Future<void> sendMessage(Map<String, dynamic> message) async {
    await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(message),
    );
  }
}
