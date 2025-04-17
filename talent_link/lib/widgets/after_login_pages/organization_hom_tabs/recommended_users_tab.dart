import 'package:flutter/material.dart';

class RecommendedUsersTab extends StatefulWidget {
  final String token;
  const RecommendedUsersTab({super.key, required this.token});

  @override
  State<RecommendedUsersTab> createState() => _RecommendedUsersTabState();
}

class _RecommendedUsersTabState extends State<RecommendedUsersTab> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(children: [Text("Recommended Users Tab")]));
  }
}
