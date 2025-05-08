import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  final String baseUrl;
  final String token;

  LocationService({required this.baseUrl, required this.token});

  Future<bool> setLocation({required double lat, required double lng}) async {
    final url = Uri.parse('$baseUrl/api/location/set');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'lat': lat, 'lng': lng}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to set location: ${response.body}');
      return false;
    }
  }

  Future<Map<String, double>> getLocationByUsername(String username) async {
    final url = Uri.parse('$baseUrl/api/location/get');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': username}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'lat': (data['lat'] as num).toDouble(),
        'lng': (data['lng'] as num).toDouble(),
      };
    } else {
      print('Failed to get location: ${response.body}');
      return {'lat': 0.0, 'lng': 0.0}; // fallback
    }
  }

  Future<List<Map<String, dynamic>>> getAllCompaniesLocations() async {
    final url = Uri.parse('$baseUrl/api/location/all');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print('Failed to fetch all companies locations: ${response.body}');
      return [];
    }
  }
}
