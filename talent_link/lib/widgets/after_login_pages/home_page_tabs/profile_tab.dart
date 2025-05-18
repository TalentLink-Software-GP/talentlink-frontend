import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:talent_link/services/post_service.dart';
import 'package:talent_link/services/profile_service.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/avatar_username.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/post_card.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/resume.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/user_data.dart';
import 'package:talent_link/models/user_profile_data.dart';
import 'package:logger/logger.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback onLogout;
  final String token;

  const ProfileTab({super.key, required this.onLogout, required this.token});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin {
  final _logger = Logger();
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    fetchProfileData();
    _postService = PostService(widget.token);
    fetchUserDataAndPosts();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchProfileData() async {
    try {
      final data = await ProfileService.getProfileData(widget.token);
      setState(() {
        userProfileData = data;
      });
    } catch (e) {
      _logger.e("Error fetching profile", error: e);
      setState(() {
        userProfileData = UserProfileData(
          summary: '',
          education: [],
          skills: [],
          experience: [],
          certifications: [],
          languages: [],
        );
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteItem(String field, String value) async {
    try {
      await ProfileService.deleteItem(field, value, widget.token);
      await fetchProfileData();
    } catch (e) {
      _logger.e("Error deleting $field", error: e);
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
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSectionIcon(title),
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                        isCollapsed ? Icons.expand_more : Icons.expand_less,
                        color: Theme.of(context).primaryColor,
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
                  const SizedBox(height: 16),
                  if (displayedItems.isEmpty)
                    Text(
                      "No data available.",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ...displayedItems.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        title: Text(
                          item,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              onPressed: () => showEditDialog(field, item),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () => deleteItem(field, item),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => showEditDialog(field, null),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      label: Text(
                        "Add New",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (items.length > 3)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            expandedSections[title] = !isExpanded;
                          });
                        },
                        child: Text(
                          isExpanded ? "Show Less ▲" : "Show More ▼",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Education':
        return Icons.school_outlined;
      case 'Skills':
        return Icons.psychology_outlined;
      case 'Experience':
        return Icons.work_outline;
      case 'Certifications':
        return Icons.card_membership_outlined;
      case 'Languages':
        return Icons.language_outlined;
      default:
        return Icons.list_alt_outlined;
    }
  }

  Future<void> fetchUserDataAndPosts() async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    String username = decodedToken['username'];
    _logger.i("Username: $username");
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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userProfileData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.9),
                        Theme.of(context).primaryColor.withOpacity(0.7),
                        Theme.of(context).primaryColor.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: AvatarUsername(token: widget.token),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                UserData(),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Summary",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              //TODO: Implement edit summary dialog
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userProfileData!.summary.isNotEmpty
                            ? userProfileData!.summary
                            : "No summary provided.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                buildExpandableList(
                  "Education",
                  userProfileData!.education,
                  'education',
                ),
                buildExpandableList(
                  "Skills",
                  userProfileData!.skills,
                  'skills',
                ),
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
                Resume(
                  token: widget.token,
                  onSkillsExtracted: fetchProfileData,
                ),
                const SizedBox(height: 20),
                const Divider(),
                if (userPosts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No posts yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
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
                                    post['isLiked'] =
                                        !(post['isLiked'] ?? false);
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
