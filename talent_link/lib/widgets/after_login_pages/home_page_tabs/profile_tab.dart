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
  final GlobalKey<SkillsEducationState> _skillsEducationKey = GlobalKey();

  Future<void> _refreshSkillsAndEducation() async {
    try {
      final state = _skillsEducationKey.currentState;
      if (state != null && mounted) {
        await Future.wait([state.refreshSkills(), state.refreshEducation()]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error refreshing skills: $e')));
      }
    }
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
                    const Divider(),
                    UserData(),
                    const Divider(),
                    SkillsEducation(
                      key: _skillsEducationKey,
                      token: widget.token,
                    ),
                    const Divider(),
                    Resume(
                      token: widget.token,
                      onSkillsExtracted: _refreshSkillsAndEducation,
                    ),
                    const Divider(),
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
