import 'package:flutter/material.dart';
import 'package:talent_link/models/job.dart';
import 'package:talent_link/services/applicationService.dart';
import 'package:talent_link/widgets/base_widgets/button.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;
  final String token;

  const JobDetailsScreen({super.key, required this.job, required this.token});

  Future<void> _applyForJob(BuildContext context) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting application...')),
      );

      // Call API to apply for job
      await ApplicationService.applyForJob(
        token: token,
        jobId: job.id,
        jobTitle: job.title,

        matchScore: job.matchScore?.toDouble() ?? 0.0,
        organizationId: job.organizationId, // Get this from the job object
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully applied for ${job.title}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying for job: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Job Details",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Job Title
                    Text(
                      job.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Salary Section
                    _buildSectionTitle(context, 'Salary'),
                    Text(
                      job.salary,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Job Type Section
                    _buildSectionTitle(context, 'Job Type'),
                    Text(
                      job.jobType,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Category Section
                    _buildSectionTitle(context, 'Category'),
                    Text(
                      job.category,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Job Location Text only
                    _buildSectionTitle(context, 'Location'),
                    Text(
                      job.location,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Description Section
                    _buildSectionTitle(context, 'Description'),
                    Text(
                      job.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Requirements Section
                    _buildSectionTitle(context, 'Requirements'),
                    Text(
                      job.requirements.join(", "),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Responsibilities Section
                    _buildSectionTitle(context, 'Responsibilities'),
                    Text(
                      job.responsibilities.join(", "),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: BaseButton(
                        onPressed: () => _applyForJob(context),
                        text: 'Apply for this Job',
                        buttonColor: Colors.green,
                      ),
                    ),
                    // Apply Button (stays at the bottom if possible)
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: BaseButton(
                    //     onPressed: () {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(
                    //           content: Text('Applying for ${job.title}...'),
                    //         ),
                    //       );
                    //     },

                    //     text: 'Apply for this Job',
                    //     buttonColor: Colors.green,
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method for creating section titles
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
