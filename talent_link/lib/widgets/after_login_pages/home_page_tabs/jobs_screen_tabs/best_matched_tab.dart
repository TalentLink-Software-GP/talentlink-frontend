import 'package:flutter/material.dart';
import 'package:talent_link/models/job.dart';
import 'package:talent_link/services/job_functions.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tabs/job_details_screen.dart';

class BestMatchedTab extends StatefulWidget {
  final String token;

  const BestMatchedTab({super.key, required this.token});

  @override
  State<BestMatchedTab> createState() => _BestMatchedTabState();
}

class _BestMatchedTabState extends State<BestMatchedTab> {
  List<Job> bestJobs = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBestMatches();
  }

  Future<void> fetchBestMatches() async {
    setState(() => isLoading = true);
    final jobs = await JobFunctions.fetchJobs(widget.token);
    setState(() {
      bestJobs = JobFunctions.sortJobsByMatchScore(jobs);
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return PageView.builder(
      itemCount: bestJobs.length,
      controller: PageController(viewportFraction: 0.8),
      itemBuilder: (context, index) {
        final job = bestJobs[index];
        return GestureDetector(
          onTap: () => _navigateToJobDetail(job),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Center(
              child: ListTile(
                title: Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Match: ${job.matchScore?.toStringAsFixed(1) ?? "0"}%',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
