import 'package:flutter/material.dart';
import 'package:talent_link/models/job.dart';
import 'package:talent_link/services/job_functions.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tabs/job_details_screen.dart';

class FilterJobsTab extends StatefulWidget {
  final String token;

  const FilterJobsTab({super.key, required this.token});

  @override
  State<FilterJobsTab> createState() => _FilterJobsTabState();
}

class _FilterJobsTabState extends State<FilterJobsTab> {
  List<Job> allJobs = [];
  List<Job> filteredJobs = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

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
      filteredJobs = List.from(jobs);
      isLoading = false;
    });
  }

  void _filterJobs(String query) {
    setState(() {
      filteredJobs = JobFunctions.filterJobs(allJobs, query);
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search jobs...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _filterJobs(_searchController.text);
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredJobs.length,
            itemBuilder: (context, index) {
              final job = filteredJobs[index];
              return ListTile(
                title: Text(job.title),
                subtitle: Text(job.category),
                onTap: () => _navigateToJobDetail(job),
              );
            },
          ),
        ),
      ],
    );
  }
}
