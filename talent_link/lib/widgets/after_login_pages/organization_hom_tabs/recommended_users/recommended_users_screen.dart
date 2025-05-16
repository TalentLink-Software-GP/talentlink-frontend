import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:talent_link/services/job_service.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/profile_widget_for_another_users.dart';

class RecommendedUsersScreen extends StatefulWidget {
  final String jobId;
  final String organizationId;
  final String token;

  const RecommendedUsersScreen({
    super.key,
    required this.jobId,
    required this.organizationId,
    required this.token,
  });

  @override
  State<RecommendedUsersScreen> createState() => _RecommendedUsersScreenState();
}

class _RecommendedUsersScreenState extends State<RecommendedUsersScreen> {
  final _logger = Logger();
  late JobService _jobMatchService;
  List<dynamic> matchedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _jobMatchService = JobService(token: widget.token);
    _loadMatchedUsers();
  }

  Future<void> _loadMatchedUsers() async {
    try {
      final users = await _jobMatchService.fetchMatchedUsers(widget.jobId);
      setState(() {
        matchedUsers = users;
        isLoading = false;
      });
    } catch (e) {
      _logger.e('Error loading matched users', error: e);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recommended Users")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : matchedUsers.isEmpty
              ? const Center(
                child: Text(
                  "No users fits for this job. Please check again Later.",
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: matchedUsers.length,
                itemBuilder: (context, index) {
                  final userMatch = matchedUsers[index];
                  final user = userMatch['userId'];
                  final matchScore = userMatch['matchScore'];

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['avatarUrl']),
                      ),
                      title: Text(user['username']),
                      subtitle: Text('Match: ${matchScore.toString()}%'),
                      onTap: () {
                        user['username'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ProfileWidgetForAnotherUsers(
                                  username: user['username'],
                                  token: widget.token,
                                ),
                          ),
                        );
                      },
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Contact logic here
                        },
                        child: const Text("Contact User"),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
