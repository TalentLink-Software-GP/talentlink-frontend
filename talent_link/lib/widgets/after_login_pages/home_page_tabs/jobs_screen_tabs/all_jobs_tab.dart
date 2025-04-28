import 'package:flutter/material.dart';
import 'package:talent_link/models/job.dart';
import 'package:talent_link/services/job_functions.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tabs/job_details_screen.dart';

class AllJobsTab extends StatefulWidget {
  final String token;

  const AllJobsTab({super.key, required this.token});

  @override
  State<AllJobsTab> createState() => _AllJobsTabState();
}

class _AllJobsTabState extends State<AllJobsTab> {
  List<Job> allJobs = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    setState(() => isLoading = true);
    final jobs = await JobFunctions.fetchJobs(widget.token);
    setState(() {
      allJobs = jobs;
      isLoading = false;
    });
  }

  void _navigateToJobDetail(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(job: job, token: widget.token),
      ),
    );
  }

  Widget build(BuildContext context) {
    if (isLoading && allJobs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: allJobs.length,
      itemBuilder: (context, index) {
        final job = allJobs[index];
        return Card(
          color: Colors.white,
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            trailing: const Icon(Icons.arrow_circle_right, color: Colors.green),
            title: Text(
              job.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              job.location,
              style: const TextStyle(color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
            onTap: () => _navigateToJobDetail(job),
          ),
        );
      },
    );
  }
}
