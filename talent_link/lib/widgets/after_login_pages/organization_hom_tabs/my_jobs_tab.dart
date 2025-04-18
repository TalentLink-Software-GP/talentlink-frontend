import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:talent_link/models/job.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/add_job_or_post_card.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/add_new_job_screen.dart';
import 'package:talent_link/widgets/base_widgets/text_field.dart';

class MyJobsTab extends StatefulWidget {
  final String token;
  const MyJobsTab({super.key, required this.token});

  @override
  State<MyJobsTab> createState() => _MyJobsTabState();
}

class _MyJobsTabState extends State<MyJobsTab> {
  List<Job> jobs = [];
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/job/getorgjobs'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          jobs = data.map((json) => Job.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print("Error fetching jobs: $e");
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:5000/api/job/deletejob?jobId=$jobId'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Job deleted successfully")));
        fetchJobs();
      }
    } catch (e) {
      print("Error deleting job: $e");
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
      setState(() {
        fetchJobs();
      });
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
