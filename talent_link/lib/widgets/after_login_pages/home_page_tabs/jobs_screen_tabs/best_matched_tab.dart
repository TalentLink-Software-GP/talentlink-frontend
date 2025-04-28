import 'package:flutter/material.dart';
import 'package:talent_link/models/job.dart';
import 'package:talent_link/services/job_functions.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tabs/job_details_screen.dart';
import 'package:talent_link/widgets/base_widgets/button.dart';

class BestMatchedTab extends StatefulWidget {
  final String token;

  const BestMatchedTab({super.key, required this.token});

  @override
  State<BestMatchedTab> createState() => _BestMatchedTabState();
}

class _BestMatchedTabState extends State<BestMatchedTab> {
  List<Job> allJobs = [];
  List<Job> bestJobs = [];
  bool isLoading = false;
  double minMatchScore = 0; // Slider value (0% initially)

  @override
  void initState() {
    super.initState();
    fetchBestMatches();
  }

  Future<void> fetchBestMatches() async {
    setState(() => isLoading = true);
    final jobs = await JobFunctions.fetchJobs(widget.token);
    setState(() {
      allJobs = JobFunctions.sortJobsByMatchScore(jobs);
      filterJobs();
      isLoading = false;
    });
  }

  void filterJobs() {
    bestJobs =
        allJobs.where((job) => (job.matchScore ?? 0) >= minMatchScore).toList();
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Minimum Match Percentage:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: minMatchScore,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${minMatchScore.round()}%',
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    minMatchScore = value;
                    filterJobs();
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            itemCount: bestJobs.length,
            controller: PageController(viewportFraction: 0.85),
            itemBuilder: (context, index) {
              final job = bestJobs[index];
              return Center(
                child: SizedBox(
                  height: 200,
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Match: ${job.matchScore?.toStringAsFixed(1) ?? "0"}%',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: BaseButton(
                              onPressed: () => _navigateToJobDetail(job),
                              text: 'Apply Now!',
                              buttonColor: Colors.green,
                            ),
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
    );
  }
}
