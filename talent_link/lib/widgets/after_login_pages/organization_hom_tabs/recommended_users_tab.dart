import 'package:flutter/material.dart';
import 'package:talent_link/models/job.dart';
import 'package:talent_link/services/job_service.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/recommended_users/recommended_users_screen.dart';
import 'package:talent_link/widgets/base_widgets/button.dart';

class RecommendedUsersTab extends StatefulWidget {
  final String token;
  const RecommendedUsersTab({super.key, required this.token});

  @override
  State<RecommendedUsersTab> createState() => _RecommendedUsersTabState();
}

class _RecommendedUsersTabState extends State<RecommendedUsersTab> {
  List<Job> jobs = [];
  late JobService jobService;

  @override
  void initState() {
    super.initState();
    jobService = JobService(token: widget.token);
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    try {
      final fetchedJobs = await jobService.fetchJobs();
      setState(() {
        jobs = fetchedJobs;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return jobs.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: BaseButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => RecommendedUsersScreen(
                                    jobId: job.id,
                                    organizationId: job.organizationId,
                                    token: widget.token,
                                  ),
                            ),
                          );
                        },
                        text: "View Recommended Users",
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }
}
