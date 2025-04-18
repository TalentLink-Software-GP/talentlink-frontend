import 'package:flutter/material.dart';
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/profile_tab_items/add_job_or_post_card.dart';

class HomeTab extends StatefulWidget {
  final String token;
  const HomeTab({super.key, required this.token});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          AddJobOrPostCard(
            token: widget.token,
            text: "Create Post",
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
