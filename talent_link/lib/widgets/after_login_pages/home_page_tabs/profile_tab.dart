import 'package:flutter/material.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/avatar_username.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/resume.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/skills_education.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/user_data.dart';

class ProfileTab extends StatefulWidget {
  final List<String> userEducation;
  final List<String> userSkills;
  final VoidCallback onLogout;
  final String token;

  const ProfileTab({
    super.key,
    required this.userEducation,
    required this.userSkills,
    required this.onLogout,
    required this.token,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String? uploadedCVUrl;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.minHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarUsername(token: widget.token),
                    Divider(),
                    UserData(),
                    Divider(),
                    SkillsEducation(token: widget.token),
                    Divider(),
                    Resume(token: widget.token),
                    Divider(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
