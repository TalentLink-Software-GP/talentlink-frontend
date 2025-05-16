import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:talent_link/models/job.dart';
import 'package:logger/logger.dart';

class JobService {
  final String token;
  static const String baseUrl = 'http://10.0.2.2:5000/api/job';
  final _logger = Logger();

  JobService({required this.token});
  Future<Job> fetchJobById(String jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/job/$jobId'),
        // headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Job.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Job not found');
      } else {
        throw Exception('Failed to load job');
      }
    } catch (e) {
      _logger.e("Error fetching job:", error: e);
      rethrow;
    }
  }

  Future<List<Job>> fetchJobs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getorgjobs'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Job.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      _logger.e("Error fetching jobs:", error: e);
      rethrow;
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deletejob?jobId=$jobId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete job');
      }
    } catch (e) {
      _logger.e("Error deleting job:", error: e);
      rethrow;
    }
  }

  Future<List<Job>> fetchUserJobs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getAllJobsUser'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Job.fromJson(json)).toList();
      } else if (response.statusCode == 204) {
        return []; // No available jobs
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      _logger.e("Error fetching user jobs:", error: e);
      rethrow;
    }
  }

  Future<List<dynamic>> fetchMatchedUsers(String jobId) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/jobMatch/getMatchSortedByScore'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'jobId': jobId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load matched users');
    }
  }
}
