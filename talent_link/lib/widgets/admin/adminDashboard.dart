import 'package:flutter/material.dart';
import 'package:talent_link/widgets/admin/adminSettingsPage%20.dart';
import 'package:talent_link/widgets/admin/adminStatisticsPage.dart';
import 'package:talent_link/widgets/admin/managePostsPage.dart';
import 'package:talent_link/widgets/admin/manageUsersPage.dart';

class AdminDashboard extends StatelessWidget {
  final String token;

  const AdminDashboard({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 122, 53, 53),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminSettingsPage(token: token),
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildCard(
            context,
            title: 'Manage Users',
            icon: Icons.people,
            color: const Color.fromARGB(255, 6, 82, 145),
            page: ManageUsersPage(token: token),
          ),
          _buildCard(
            context,
            title: 'Manage Posts',
            icon: Icons.post_add,
            color: const Color.fromARGB(255, 66, 24, 0),
            page: ManagePostsPage(token: token),
          ),
          _buildCard(
            context,
            title: 'Statistics',
            icon: Icons.analytics,
            color: const Color.fromARGB(255, 38, 109, 41),
            page: AdminStatisticsPage(token: token),
          ),
          _buildCard(
            context,
            title: 'Reports',
            icon: Icons.analytics,
            color: const Color.fromARGB(255, 218, 75, 75),
            page: AdminStatisticsPage(token: token),
          ),
          _buildCard(
            context,
            title: 'Manage Job',
            icon: Icons.analytics,
            color: const Color.fromARGB(255, 75, 77, 218),
            page: AdminStatisticsPage(token: token),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return GestureDetector(
      onTap:
          () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: color.withOpacity(0.1),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
