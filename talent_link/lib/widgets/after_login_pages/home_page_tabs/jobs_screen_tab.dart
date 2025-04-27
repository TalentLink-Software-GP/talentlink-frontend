import 'package:flutter/material.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tabs/all_jobs_tab.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tabs/best_matched_tab.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tabs/filter_jobs_tab.dart';

class JobsScreenTab extends StatefulWidget {
  final String token;

  const JobsScreenTab({super.key, required this.token});

  @override
  State<JobsScreenTab> createState() => _JobsScreenTabState();
}

class _JobsScreenTabState extends State<JobsScreenTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'All Jobs'),
          Tab(text: 'Best Matches'),
          Tab(text: 'Filter Jobs'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AllJobsTab(token: widget.token),
          BestMatchedTab(token: widget.token),
          FilterJobsTab(token: widget.token),
        ],
      ),
    );
  }
}
