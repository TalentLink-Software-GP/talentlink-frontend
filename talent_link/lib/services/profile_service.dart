import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile_data.dart';

class ProfileService {
  static Future<UserProfileData> getProfileData(
    String token, {
    String? username,
  }) async {
    final uri = Uri.parse('http://10.0.2.2:5000/api/skills/get-all');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = username != null ? json.encode({'username': username}) : null;

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      return UserProfileData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile data: ${response.body}');
    }
  }

  static Future<void> deleteItem(
    String field,
    String value,
    String token,
  ) async {
    print('field: $field value: $value token: $token');
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:5000/api/skills/delete-$field'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({field: value}),
    );

    if (response.statusCode != 200) {
      print(response.statusCode);
      throw Exception('Failed to delete $field');
    }
  }

  static Future<void> addItem(String field, String value, String token) async {
    print('field: $field value: $value token: $token');
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/skills/add-$field'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'item': value}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add $field');
    }
  }

  static Future<void> updateItem(
    String field,
    String oldValue,
    String newValue,
    String token,
  ) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:5000/api/skills/update-$field'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'oldItem': oldValue, 'newItem': newValue}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update $field');
    }
  }
}
