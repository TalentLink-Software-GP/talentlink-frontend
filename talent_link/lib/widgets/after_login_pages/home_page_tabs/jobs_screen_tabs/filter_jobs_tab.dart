import 'package:flutter/material.dart';
import 'package:talent_link/models/job.dart';
import 'package:talent_link/services/job_functions.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tabs/job_details_screen.dart';
import 'package:talent_link/widgets/base_widgets/text_field.dart';

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

  String? selectedJobType;
  String? selectedLocation;
  String? selectedCategory;

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

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredJobs =
          allJobs.where((job) {
            final matchesQuery =
                job.title.toLowerCase().contains(query) ||
                job.category.toLowerCase().contains(query) ||
                job.location.toLowerCase().contains(query) ||
                job.description.toLowerCase().contains(query);

            final matchesJobType =
                selectedJobType == null || job.jobType == selectedJobType;
            final matchesLocation =
                selectedLocation == null || job.location == selectedLocation;
            final matchesCategory =
                selectedCategory == null || job.category == selectedCategory;

            return matchesQuery &&
                matchesJobType &&
                matchesLocation &&
                matchesCategory;
          }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      selectedJobType = null;
      selectedLocation = null;
      selectedCategory = null;
      filteredJobs = List.from(allJobs);
    });
  }

  void _showFilterDialog() {
    final jobTypes = allJobs.map((job) => job.jobType).toSet().toList();
    final locations = allJobs.map((job) => job.location).toSet().toList();
    final categories = allJobs.map((job) => job.category).toSet().toList();

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Jobs',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildDropdown(
                            label: "Job Type",
                            value: selectedJobType,
                            items: jobTypes,
                            onChanged: (value) {
                              setState(() {
                                selectedJobType = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: "Location",
                            value: selectedLocation,
                            items: locations,
                            onChanged: (value) {
                              setState(() {
                                selectedLocation = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: "Category",
                            value: selectedCategory,
                            items: categories,
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              selectedJobType = null;
                              selectedLocation = null;
                              selectedCategory = null;
                              _applyFilters();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: DropdownButtonFormField<String>(
            isExpanded: true, // important to make it take full width
            value: value,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            items:
                items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis, // handle overflow
                      softWrap: true, // allow wrapping of long text
                    ),
                  );
                }).toList(),
            onChanged: onChanged,
          ),
        );
      },
    );
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
          child: Row(
            children: [
              Expanded(
                child: MyTextFieled(
                  controller: _searchController,
                  textHint: 'Search jobs...',
                  textLable: 'Search',
                  obscureText: false,
                  onChanged: (value) {
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.filter_list,
                  size: 32,
                  color: Colors.green,
                ),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child:
              filteredJobs.isEmpty
                  ? const Center(child: Text('No jobs found.'))
                  : ListView.builder(
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      return Card(
                        elevation: 3,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          trailing: const Icon(
                            Icons.arrow_circle_right,
                            color: Colors.green,
                          ),
                          title: Text(
                            job.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          subtitle: Text(
                            job.category,
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () => _navigateToJobDetail(job),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
