import 'package:flutter/material.dart';
import 'package:talent_link/services/message_service.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/applications_tab.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/home_tab.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/my_jobs_tab.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/recommended_users_tab.dart';

class OrganizationHomePage extends StatefulWidget {
  final String token;
  const OrganizationHomePage({super.key, required this.token});

  @override
  State<OrganizationHomePage> createState() => _OrganizationHomePageState();
}

class _OrganizationHomePageState extends State<OrganizationHomePage> {
  int _selectedIndex = 0;

  late MessageService _messageService;
  @override
  void initState() {
    super.initState();
    _messageService = MessageService(widget.token);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleSearchNavigation() {
    _messageService.navigateToSearchPage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Talent Link")),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.black,
          fontSize: 23,
        ),

        ////work here
        leading: IconButton(
          icon: const Icon(Icons.message),
          onPressed: _handleSearchNavigation,
          color: Colors.white,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeTab(token: widget.token),
            MyJobsTab(token: widget.token),
            ApplicationsTab(token: widget.token),
            RecommendedUsersTab(token: widget.token),
            ProfileTab(token: widget.token),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: "My Jobs"),
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inbox),
            label: "Applications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: "Recommended",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assured_workload),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
