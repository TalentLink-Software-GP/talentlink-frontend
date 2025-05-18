import 'package:flutter/material.dart';
import 'package:talent_link/models/job.dart';
import 'package:talent_link/services/job_functions.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tabs/job_details_screen.dart';
import 'package:talent_link/widgets/shared/job_card.dart';

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
  bool _mounted = true;

  String? selectedJobType;
  String? selectedLocation;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _mounted = true;
    fetchJobs();
  }

  @override
  void dispose() {
    _mounted = false;
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchJobs() async {
    if (!_mounted) return;

    setState(() => isLoading = true);

    try {
      final jobs = await JobFunctions.fetchJobs(widget.token);

      if (!_mounted) return;

      // Schedule setState on next frame to avoid blocking main thread
      Future.microtask(() {
        if (!_mounted) return;
        setState(() {
          allJobs = jobs;
          filteredJobs = List.from(jobs);
          isLoading = false;
        });
      });
    } catch (e) {
      if (!_mounted) return;

      setState(() {
        isLoading = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load jobs. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _applyFilters() {
    if (!_mounted) return;

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

  void _showFilterDialog() {
    final jobTypes = allJobs.map((job) => job.jobType).toSet().toList();
    final locations = allJobs.map((job) => job.location).toSet().toList();
    final categories = allJobs.map((job) => job.category).toSet().toList();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Jobs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildFilterDropdown(
                          label: "Job Type",
                          value: selectedJobType,
                          items: jobTypes,
                          onChanged: (value) {
                            setState(() => selectedJobType = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFilterDropdown(
                          label: "Location",
                          value: selectedLocation,
                          items: locations,
                          onChanged: (value) {
                            setState(() => selectedLocation = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildFilterDropdown(
                          label: "Category",
                          value: selectedCategory,
                          items: categories,
                          onChanged: (value) {
                            setState(() => selectedCategory = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            selectedJobType = null;
                            selectedLocation = null;
                            selectedCategory = null;
                            _applyFilters();
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.colorScheme.outline),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Clear All',
                          style: TextStyle(color: theme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _applyFilters();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
    );
  }

  void _navigateToJobDetail(Job job) {
    if (!_mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(job: job, token: widget.token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search jobs...',
                    prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.tune, color: theme.primaryColor),
                  onPressed: _showFilterDialog,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              filteredJobs.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matching jobs found',
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      return JobCard(
                        job: job,
                        onTap: () => _navigateToJobDetail(job),
                        isCompact: true,
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
