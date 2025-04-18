import 'package:flutter/material.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/avatar_name.dart';

class ProfileTab extends StatefulWidget {
  final String token;
  const ProfileTab({super.key, required this.token});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [AvatarName(token: widget.token), Divider()],
    );
  }
}
