import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:talent_link/models/job.dart';

class JobService {
  final String token;
  static const String baseUrl = 'http://10.0.2.2:5000/api/job';

  JobService({required this.token});

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
      print("Error fetching jobs: $e");
      throw e;
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
      print("Error deleting job: $e");
      throw e;
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
      print("Error fetching user jobs: $e");
      throw e;
    }
  }
}
