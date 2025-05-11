import 'dart:convert';
import 'package:http/http.dart' as http;

class OrganizationService {
  final String baseUrl;
  final String token;

  OrganizationService({required this.baseUrl, required this.token});

  Future<Map<String, dynamic>> getOrganizationProfile({
    String? organizationId,
  }) async {
    final uri = Uri.parse('$baseUrl/getOrgData');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(organizationId != null ? {'id': organizationId} : {}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch organization data: ${response.body}');
    }
  }
}
