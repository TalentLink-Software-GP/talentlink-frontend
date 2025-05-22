import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:talent_link/models/job.dart';
import 'package:talent_link/services/job_service.dart';
import 'package:talent_link/services/organization_service.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/add_job_or_post_card.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/add_new_job_screen.dart';

class MyJobsTab extends StatefulWidget {
  final String token;
  const MyJobsTab({super.key, required this.token});

  @override
  State<MyJobsTab> createState() => _MyJobsTabState();
}

class _MyJobsTabState extends State<MyJobsTab> {
  final logger = Logger();
  List<Job> jobs = [];
  String? avatarUrl;

  late JobService jobService;
  late OrganizationService _orgService;

  @override
  void initState() {
    super.initState();
    jobService = JobService(token: widget.token);
    _orgService = OrganizationService(
      //192.168.1.7        baseUrl: 'http://10.0.2.2:5000/api/organization',
      // baseUrl: 'http://192.168.1.7:5000/api/organization',
      token: widget.token,
    );
    fetchJobs();
    fetchOrgData();
  }

  Future<void> fetchOrgData() async {
    try {
      final data = await _orgService.getOrganizationProfile();
      if (!mounted) return;
      setState(() {
        avatarUrl = data['avatarUrl'];
      });
    } catch (e) {
      logger.e("Error fetching organization profile", error: e);
    }
  }

  Future<void> fetchJobs() async {
    try {
      final fetchedJobs = await jobService.fetchJobs();
      setState(() {
        jobs = fetchedJobs;
      });
    } catch (e) {
      logger.e("Error fetching jobs", error: e);
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await jobService.deleteJob(jobId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Job deleted successfully"),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      fetchJobs();
    } catch (e) {
      logger.e("Error deleting job", error: e);
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

  void showJobDetails(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (_, controller) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: controller,
                          padding: EdgeInsets.all(20),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    job.title,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            _buildDetailRow(
                              Icons.business_center_outlined,
                              'Job Type',
                              job.jobType,
                            ),
                            _buildDetailRow(
                              Icons.location_on_outlined,
                              'Location',
                              job.location,
                            ),
                            _buildDetailRow(
                              Icons.calendar_today_outlined,
                              'Deadline',
                              job.deadline.split('T')[0],
                            ),
                            _buildDetailRow(
                              Icons.attach_money,
                              'Salary',
                              job.salary,
                            ),
                            _buildDetailRow(
                              Icons.category_outlined,
                              'Category',
                              job.category,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              job.description,
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                            if (job.requirements.isNotEmpty) ...[
                              SizedBox(height: 16),
                              Text(
                                'Requirements',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              ...job.requirements.map(
                                (req) => Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 18,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          req,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (job.responsibilities.isNotEmpty) ...[
                              SizedBox(height: 16),
                              Text(
                                'Responsibilities',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              ...job.responsibilities.map(
                                (resp) => Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 18,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          resp,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF5F5F5),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 16,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child:
                      avatarUrl == null
                          ? Icon(
                            Icons.person_outline,
                            color: Colors.grey[600],
                            size: 20,
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => showJobDialog(),
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                'Add New Job',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.add, color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                jobs.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No jobs posted yet",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: jobs.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => showJobDetails(job),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            job.title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(
                                                  Icons.edit_outlined,
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                  size: 18,
                                                ),
                                                onPressed:
                                                    () => showJobDialog(
                                                      isUpdate: true,
                                                      job: job,
                                                    ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red[400],
                                                  size: 18,
                                                ),
                                                onPressed: () async {
                                                  final confirm = await showDialog<
                                                    bool
                                                  >(
                                                    context: context,
                                                    builder:
                                                        (_) => AlertDialog(
                                                          title: const Text(
                                                            'Delete Job',
                                                          ),
                                                          content: const Text(
                                                            'Are you sure you want to delete this job?',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                        false,
                                                                      ),
                                                              child: Text(
                                                                'Cancel',
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                        true,
                                                                      ),
                                                              child: Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red[400],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                  );
                                                  if (confirm == true)
                                                    deleteJob(job.id);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 4,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.business_center_outlined,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                job.jobType,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                job.location,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            "Deadline: ${job.deadline.split('T')[0]}",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
