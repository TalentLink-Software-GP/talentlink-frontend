import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:talent_link/services/post_service.dart';
import 'package:talent_link/services/profile_service.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/avatar_username.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/post_card.dart';
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
  late PostService _postService;
  UserProfileData? userProfileData;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  Map<String, bool> expandedSections = {};
  Map<String, bool> collapsedSections = {};
  List<Map<String, dynamic>> userPosts = [];
  String? fullName;
  final int _page = 1;
  final int _limit = 10;
  String? uploadedImageUrl;
  bool _hasMore = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    _postService = PostService(widget.token);
    fetchUserDataAndPosts();
  }

  Future<void> fetchProfileData() async {
    try {
      final data = await ProfileService.getProfileData(widget.token);
      setState(() {
        userProfileData = data;
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
    final isCollapsed = collapsedSections[title] ?? true;
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
                  IconButton(
                    icon: Icon(
                      isCollapsed
                          ? Icons.label_important_outline
                          : Icons.label_important,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        collapsedSections[title] =
                            !(collapsedSections[title] ?? false);
                      });
                    },
                  ),
                ],
              ),
              if (!isCollapsed) ...[
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchUserDataAndPosts() async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    String username = decodedToken['username'];
    print("Username: $username");
    try {
      final userResponse = await _postService.fetchUserByUsername(username);

      final postsResponse = await _postService.fetchPostsByUsername(
        username,
        _page,
        _limit,
      );

      setState(() {
        // Process user data
        userData = userResponse;
        uploadedImageUrl = userResponse['avatarUrl'];
        fullName = userResponse['name'];
        username = userResponse['username'];

        // Process posts
        userPosts =
            postsResponse.map<Map<String, dynamic>>((post) {
              return {
                'text': post['content'],
                'author': post['author'],
                'time': DateTime.parse(post['createdAt']),
                'avatarUrl': post['avatarUrl'] ?? '',
                'id': post['_id'],
                'isLiked': post['isLiked'] ?? false,
                'likeCount': post['likeCount'] ?? 0,
                'comments': List<Map<String, dynamic>>.from(
                  (post['comments'] ?? []).map(
                    (c) => {
                      '_id': c['_id'],
                      'text': c['text'],
                      'author': c['author'],
                      'avatarUrl': c['avatarUrl'],
                    },
                  ),
                ),
              };
            }).toList();

        _hasMore = postsResponse.length == _limit;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: ${e.toString()}')),
      );
      debugPrint('Error in fetchUserDataAndPosts: $e');
      // Add this to see the full URL being called
      debugPrint(
        'Attempted URL: ${_postService.baseUrl}/posts/getuser-posts-byusername/$username?page=$_page&limit=$_limit',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userProfileData == null) {
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Summary",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      //TODO: Implement edit summary dialog or page
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
                  userProfileData!.summary.isNotEmpty
                      ? userProfileData!.summary
                      : "No summary provided.",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const Divider(),

            buildExpandableList(
              "Education",
              userProfileData!.education,
              'education',
            ),
            buildExpandableList("Skills", userProfileData!.skills, 'skills'),
            buildExpandableList(
              "Experience",
              userProfileData!.experience,
              'experience',
            ),
            buildExpandableList(
              "Certifications",
              userProfileData!.certifications,
              'certifications',
            ),
            buildExpandableList(
              "Languages",
              userProfileData!.languages,
              'languages',
            ),

            Resume(token: widget.token, onSkillsExtracted: fetchProfileData),
            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 10),
            if (userPosts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No posts found'),
              )
            else
              Column(
                children:
                    userPosts.map((post) {
                      final authorName = fullName ?? 'Unknown Author';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: PostCard(
                          postId: post['id'],
                          postText: post['text'],
                          authorName: authorName,

                          timestamp: post['time'],
                          authorAvatarUrl: post['avatarUrl'] ?? '',
                          isOwner: false,
                          isLiked: post['isLiked'] ?? false,
                          likeCount: post['likeCount'] ?? 0,
                          onLike: () async {
                            try {
                              setState(() {
                                post['isLiked'] = !(post['isLiked'] ?? false);
                                if (post['isLiked']) {
                                  post['likeCount'] =
                                      (post['likeCount'] ?? 0) + 1;
                                } else {
                                  post['likeCount'] =
                                      (post['likeCount'] ?? 1) - 1;
                                }
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to like post: $e'),
                                ),
                              );
                            }
                          },
                          onComment: () {},
                          currentUserAvatar: userData?['avatarUrl'] ?? '',
                          currentUserName: userData?['username'] ?? '',
                          token: widget.token,
                          initialComments: List<Map<String, dynamic>>.from(
                            (post['comments'] ?? []).map(
                              (c) => {
                                '_id': c['_id'],
                                'text': c['text'],
                                'author': c['author'],
                                'avatarUrl': c['avatarUrl'],
                              },
                            ),
                          ),
                          username: authorName,
                          onDelete: null,
                          onUpdate: null,
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
