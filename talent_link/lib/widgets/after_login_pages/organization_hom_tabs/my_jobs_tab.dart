import 'package:flutter/material.dart';
import 'package:talent_link/models/job.dart';
import 'package:talent_link/services/job_service.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/add_job_or_post_card.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/add_new_job_screen.dart';

class MyJobsTab extends StatefulWidget {
  final String token;
  const MyJobsTab({super.key, required this.token});

  @override
  State<MyJobsTab> createState() => _MyJobsTabState();
}

class _MyJobsTabState extends State<MyJobsTab> {
  List<Job> jobs = [];
  int? expandedIndex;

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

  Future<void> deleteJob(String jobId) async {
    try {
      await jobService.deleteJob(jobId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Job deleted successfully")));
      fetchJobs();
    } catch (e) {
      print('Error: $e');
    }
  }

  void showJobDialog({bool isUpdate = false, Job? job}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => AddNewJobScreen(
              token: widget.token,
              jobToEdit: isUpdate ? job?.toJson() : null,
            ),
      ),
    );
    if (result == true) {
      fetchJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddJobOrPostCard(
          token: widget.token,
          text: "Add New Job",
          onPressed: () => showJobDialog(),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final isExpanded = expandedIndex == index;

              return Card(
                margin: EdgeInsets.all(8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      expandedIndex = isExpanded ? null : index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${job.jobType} • ${job.location} • Deadline: ${job.deadline.split('T')[0]}",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed:
                                      () => showJobDialog(
                                        isUpdate: true,
                                        job: job,
                                      ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            title: Text('Delete Job'),
                                            content: Text(
                                              'Are you sure you want to delete this job?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child: Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          ),
                                    );
                                    if (confirm == true) deleteJob(job.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          SizedBox(height: 10),
                          Text("Description: ${job.description}"),
                          SizedBox(height: 4),
                          Text("Salary: ${job.salary}"),
                          SizedBox(height: 4),
                          Text("Category: ${job.category}"),
                          SizedBox(height: 4),
                          if (job.requirements.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Requirements:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                ...job.requirements.map((r) => Text("• $r")),
                              ],
                            ),
                          if (job.responsibilities.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  "Responsibilities:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                ...job.responsibilities.map(
                                  (r) => Text("• $r"),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
