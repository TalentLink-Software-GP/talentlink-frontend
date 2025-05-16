import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Application {
  final String id;
  final String userName;
  final String jobTitle;
  final double matchScore;
  final DateTime appliedDate;
  final String status;

  Application({
    required this.id,
    required this.userName,
    required this.jobTitle,
    required this.matchScore,
    required this.appliedDate,
    required this.status,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['_id'] ?? '',
      userName: json['userName'] ?? 'Unknown User',
      jobTitle: json['jobTitle'] ?? 'Unknown Job',
      matchScore: (json['matchScore'] ?? 0).toDouble(),
      appliedDate:
          DateTime.tryParse(json['appliedDate'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }
}

class ApplicationService {
  static final _logger = Logger();

  static Future<void> applyForJob({
    required String token,
    required String jobId,
    required String jobTitle,
    required double matchScore,
    String? organizationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/applications/data'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'jobId': jobId,
          'jobTitle': jobTitle,
          'matchScore': matchScore,
          'organizationId': organizationId,
        }),
      );
      // print(
      //   "📦 Payload sent to backend: ${jsonEncode({'jobId': jobId, 'jobTitle': jobTitle, 'matchScore': matchScore, 'organizationId': organizationId})}",
      // );
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to apply for job: ${response.body}');
      }
    } catch (e) {
      _logger.e('Exception during API call:', error: e);
      rethrow;
    }
  }

  static Future<List<Application>> getOrganizationApplications(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/applications/organization'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Application.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load applications: ${response.body}');
    }
  }
}
