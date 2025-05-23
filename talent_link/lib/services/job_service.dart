import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:talent_link/models/job.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class JobService {
  final String token;
  static String get baseUrl {
    final apiUrl =
        dotenv.env['API_URL'] ??
        'https://talentlink-backend-879841675037.europe-west1.run.app/api';
    return '$apiUrl/job';
  }

  final _logger = Logger();

  JobService({required this.token});

  Future<Job> fetchJobById(String jobId) async {
    try {
      _logger.i('Fetching job with ID: $jobId');
      _logger.i('Using base URL: $baseUrl');

      final response = await http.get(
        Uri.parse('$baseUrl/job/$jobId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Job.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Job not found');
      } else {
        throw Exception('Failed to load job: ${response.body}');
      }
    } catch (e) {
      _logger.e("Error fetching job:", error: e);
      rethrow;
    }
  }

  Future<List<Job>> fetchJobs() async {
    try {
      _logger.i('Fetching jobs');
      _logger.i('Using base URL: $baseUrl');

      final response = await http.get(
        Uri.parse('$baseUrl/getorgjobs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Job.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jobs: ${response.body}');
      }
    } catch (e) {
      _logger.e("Error fetching jobs:", error: e);
      rethrow;
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      _logger.i('Deleting job with ID: $jobId');
      _logger.i('Using base URL: $baseUrl');

      final response = await http.delete(
        Uri.parse('$baseUrl/deletejob?jobId=$jobId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete job: ${response.body}');
      }
    } catch (e) {
      _logger.e("Error deleting job:", error: e);
      rethrow;
    }
  }

  Future<List<Job>> fetchUserJobs() async {
    try {
      _logger.i('Fetching user jobs');
      _logger.i('Using base URL: $baseUrl');

      final response = await http.get(
        Uri.parse('$baseUrl/getAllJobsUser'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _logger.i('Response status: ${response.statusCode}');
      _logger.i('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Job.fromJson(json)).toList();
      } else if (response.statusCode == 204) {
        return []; // No available jobs
      } else {
        _logger.e(
          "Failed to load jobs. Status code: ${response.statusCode}, Response: ${response.body}",
        );
        throw Exception(
          'Failed to load jobs: Server returned status code ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e(
        "Error fetching user jobs:",
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  Future<List<dynamic>> fetchMatchedUsers(
    String jobId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${dotenv.env['API_URL'] ?? 'http://10.0.2.2:5000/api'}/jobMatch/getMatchSortedByScore',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'jobId': jobId, 'page': page, 'pageSize': pageSize}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load matched users');
    }
  }
}
