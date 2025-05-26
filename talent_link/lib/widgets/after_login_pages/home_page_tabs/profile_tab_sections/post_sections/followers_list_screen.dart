import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:talent_link/models/followSys.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/profile_widget_for_another_users.dart';

final String baseUrl = dotenv.env['BASE_URL']!;

class FollowersListScreen extends StatefulWidget {
  final String token;
  final String username;
  final bool showFollowers; // true for followers, false for following

  const FollowersListScreen({
    super.key,
    required this.token,
    required this.username,
    required this.showFollowers,
  });

  @override
  State<FollowersListScreen> createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends State<FollowersListScreen> {
  List<FollowerUser> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/users/follow-list/${widget.username}/${widget.showFollowers ? 'followers' : 'following'}',
        ),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          users = data.map((e) => FollowerUser.fromJson(e)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showFollowers ? 'Followers' : 'Following'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          user.avatarUrl.isNotEmpty
                              ? NetworkImage(user.avatarUrl)
                              : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                    ),
                    title: Text(user.name),
                    subtitle: Text('@${user.username}'),
                    trailing:
                        user.isFollowing
                            ? OutlinedButton(
                              onPressed: () => _toggleFollow(user),
                              child: const Text('Following'),
                            )
                            : ElevatedButton(
                              onPressed: () => _toggleFollow(user),
                              child: const Text('Follow'),
                            ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProfileWidgetForAnotherUsers(
                                username: user.username,
                                token: widget.token,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }

  Future<void> _toggleFollow(FollowerUser user) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/followingSys/${user.username}/follow'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await _loadUsers(); // Refresh the list
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
