import 'package:flutter/material.dart';
import 'package:talent_link/services/search_page_services.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/profile_widget_for_another_users.dart';

class ExploreUserPage extends StatefulWidget {
  final String username;
  final String token;

  const ExploreUserPage({
    super.key,
    required this.username,
    required this.token,
  });

  @override
  State<ExploreUserPage> createState() => _ExploreUserPageState();
}

class _ExploreUserPageState extends State<ExploreUserPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];

  final SearchPageService _service = SearchPageService();

  Future<void> searchUsers(String query) async {
    final results = await _service.searchUsers(query);
    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Users"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  searchUsers(query);
                } else {
                  setState(() {
                    searchResults = [];
                  });
                }
              },
            ),
          ),

          // Results List
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final user = searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        user['avatarUrl'] != null
                            ? NetworkImage(user['avatarUrl'])
                            : AssetImage('assets/images/avatarPlaceholder.jpg')
                                as ImageProvider,
                  ),
                  title: Text(user['username']),
                  subtitle: Text(user['email'] ?? ""),
                  onTap: () {
                    final usernamePeer = user['username'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ProfileWidgetForAnotherUsers(
                              username: usernamePeer,

                              token: widget.token,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
