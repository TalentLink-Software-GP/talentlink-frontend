import 'package:flutter/material.dart';
import 'package:talent_link/services/profile_service.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/avatar_username.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/resume.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/user_data.dart';
import 'package:talent_link/models/user_profile_data.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback onLogout;
  final String token;

  const ProfileTab({super.key, required this.onLogout, required this.token});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserProfileData? userData;
  bool isLoading = true;
  Map<String, bool> expandedSections = {};

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final data = await ProfileService.getProfileData(widget.token);
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> deleteItem(String field, String value) async {
    try {
      await ProfileService.deleteItem(field, value, widget.token);
      await fetchProfileData();
    } catch (e) {
      print("Error deleting $field: $e");
    }
  }

  void showEditDialog(String field, String? oldValue) {
    final controller = TextEditingController(text: oldValue ?? '');

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(oldValue == null ? "Add $field" : "Edit $field"),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(labelText: "Enter $field"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newValue = controller.text.trim();
                  Navigator.pop(context);

                  if (newValue.isNotEmpty) {
                    if (oldValue == null) {
                      await ProfileService.addItem(
                        field,
                        newValue,
                        widget.token,
                      );
                    } else {
                      await ProfileService.updateItem(
                        field,
                        oldValue,
                        newValue,
                        widget.token,
                      );
                    }
                    await fetchProfileData();
                  }
                },
                child: Text(oldValue == null ? "Add" : "Update"),
              ),
            ],
          ),
    );
  }

  Widget buildExpandableList(String title, List<String> items, String field) {
    final isExpanded = expandedSections[title] ?? false;
    final displayedItems = isExpanded ? items : items.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.label_important, color: Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 10),
              if (displayedItems.isEmpty)
                const Text(
                  "No data available.",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ...displayedItems.map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: GestureDetector(
                    child: Text(item),
                    onTap: () => showEditDialog(field, item),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => deleteItem(field, item),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => showEditDialog(field, null),
                icon: const Icon(Icons.add),
                label: const Text("Add New"),
              ),
              if (items.length > 3)
                TextButton(
                  onPressed: () {
                    setState(() {
                      expandedSections[title] = !isExpanded;
                    });
                  },
                  child: Text(isExpanded ? "Show Less ▲" : "Show More ▼"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AvatarUsername(token: widget.token),
            const Divider(),
            UserData(),
            const Divider(),

            buildExpandableList("Education", userData!.education, 'education'),
            buildExpandableList("Skills", userData!.skills, 'skills'),
            buildExpandableList(
              "Experience",
              userData!.experience,
              'experience',
            ),
            buildExpandableList(
              "Certifications",
              userData!.certifications,
              'certifications',
            ),
            buildExpandableList("Languages", userData!.languages, 'languages'),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Summary:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Implement edit summary dialog or page
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  userData!.summary.isNotEmpty
                      ? userData!.summary
                      : "No summary provided.",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const Divider(),

            Resume(token: widget.token, onSkillsExtracted: fetchProfileData),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
