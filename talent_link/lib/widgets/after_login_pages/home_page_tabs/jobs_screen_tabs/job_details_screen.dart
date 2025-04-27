import 'package:flutter/material.dart';
import 'package:talent_link/models/job.dart';
import 'package:flutter/services.dart'; // For clipboard copying

class JobDetailsScreen extends StatelessWidget {
  final Job job;
  final String token;

  const JobDetailsScreen({super.key, required this.job, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title
              Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 8),

              // Job Location
              Text(
                'Location: ${job.location}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 8),

              // Job Description
              Text(
                'Description: ${job.description}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 8),

              // Job Salary
              Text(
                'Salary: ${job.salary}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 8),

              // Job Type
              Text(
                'Job Type: ${job.jobType}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 8),

              // Job Category
              Text(
                'Category: ${job.category}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 8),

              // Job Requirements
              Text(
                'Requirements: ${job.requirements.join(", ")}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 8),

              // Job Responsibilities
              Text(
                'Responsibilities: ${job.responsibilities.join(", ")}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 20),

              // Apply Button
              ElevatedButton(
                onPressed: () {
                  // Implement the application submission logic here
                  // For now, show a simple snackbar for demo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Applying for ${job.title}...')),
                  );
                },
                child: Text('Apply for this Job'),
              ),
              SizedBox(height: 20),

              // Share Button
              ElevatedButton.icon(
                onPressed: () {
                  // Shareable link logic here
                  final String shareableLink =
                      'https://yourapp.com/job/${job.id}';
                  Clipboard.setData(ClipboardData(text: shareableLink));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Shareable link copied to clipboard!'),
                    ),
                  );
                },
                icon: Icon(Icons.share),
                label: Text('Share this Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
