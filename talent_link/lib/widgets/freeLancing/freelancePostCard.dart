import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/mesage_profile.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/profile_widget_for_another_users.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab.dart'; // <-- Add this import

class FreelancePostCard extends StatelessWidget {
  final String username;
  final String content;
  final String date;
  final String userId;

  const FreelancePostCard({
    required this.username,
    required this.content,
    required this.date,
    required this.userId,
    super.key,
  });

  Future<String> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'defaultUsername';
  }

  Future<String> getCurrentUserid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? 'defaultUserId';
  }

  Future<String> getCurrentUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? 'defaulttoken';
  }

  Future<String> getCurrentUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatarUrl') ?? 'defaulttoken';
  }

  Future<void> _goToUserProfile(BuildContext context) async {
    final currentUsername = await getCurrentUsername();
    final token = await getCurrentUserToken();

    if (username == currentUsername) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileTab(onLogout: () {}, token: token),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ProfileWidgetForAnotherUsers(
                username: username,
                token: token,
              ),
        ),
      );
    }
  }

  Future<void> _goToChatPage(BuildContext context) async {
    final userid = await getCurrentUserid();
    final token = await getCurrentUserToken();
    final currentUserAvatarUrl = await getCurrentUserAvatar();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatPage(
              currentUserId: userid,
              peerUserId: userId,
              peerUsername: username,
              currentuserAvatarUrl: currentUserAvatarUrl,
              token: token,
              onChatClosed: () => Navigator.pop(context),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getCurrentUsername(),
      builder: (context, snapshot) {
        final isSelf = snapshot.data == username;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _goToUserProfile(context),
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(content),
                const SizedBox(height: 8),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (!isSelf)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _goToChatPage(context),
                      icon: const Icon(Icons.contact_page),
                      label: const Text("Contact"),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
