import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:talent_link/models/user_profile_data.dart';
import 'package:talent_link/services/application_service.dart';
import 'package:talent_link/services/post_service.dart';
import 'package:talent_link/services/profile_service.dart';
import 'package:talent_link/utils/pdfViewr.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/followers_list_screen.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/post_card.dart';
import 'package:logger/logger.dart';

final String baseUrl = dotenv.env['BASE_URL']!;

class ProfileWidgetForAnotherUsers extends StatefulWidget {
  final String username;
  final String token;

  const ProfileWidgetForAnotherUsers({
    super.key,
    required this.username,
    required this.token,
  });

  @override
  State<ProfileWidgetForAnotherUsers> createState() =>
      _ProfileWidgetForAnotherUsersState();
}

class _ProfileWidgetForAnotherUsersState
    extends State<ProfileWidgetForAnotherUsers> {
  final _logger = Logger();
  late PostService _postService;
  Map<String, dynamic>? userData;
  Map<String, bool> expandedSections = {};
  Map<String, bool> collapsedSections = {};
  List<Map<String, dynamic>> userPosts = [];
  bool isLoading = true;
  bool _isLoading = true;
  final int _page = 1;
  final int _limit = 10;
  String? username;
  String? uploadedImageUrl;
  String? fullName;
  UserProfileData? userProfileData;
  bool isFollowing = false;
  bool isFollowLoading = false;
  int followersCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    _postService = PostService(widget.token);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      fetchProfileData(),
      fetchFollowerStats(),
      fetchUserDataAndPosts(),
    ]);
    await checkFollowStatus();
  }

  Future<void> fetchProfileData() async {
    try {
      final data = await ProfileService.getProfileData(
        widget.token,
        username: widget.username,
      );
      setState(() {
        userProfileData = data;
        isLoading = false;
      });
    } catch (e) {
      _logger.e("Error fetching profile", error: e);
    }
  }

  Future<void> fetchUserDataAndPosts() async {
    try {
      final userResponse = await _postService.fetchUserByUsername(
        widget.username,
      );

      final postsResponse = await _postService.fetchPostsByUsername(
        widget.username,
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
        'Attempted URL: ${_postService.baseUrl}/posts/getuser-posts-byusername/${widget.username}?page=$_page&limit=$_limit',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> checkFollowStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/followingStatus/${widget.username}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          isFollowing = responseData['isFollowing'] ?? false;
        });
      } else {
        setState(() {
          isFollowing = false;
        });
      }
    } catch (e) {
      setState(() {
        isFollowing = false;
      });
    }
  }

  Future<void> toggleFollow() async {
    if (!mounted) return;

    setState(() {
      isFollowLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/followingSys/${widget.username}/follow'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Immediately update UI optimistically
        setState(() {
          isFollowing = !isFollowing;
        });

        // Then verify with server
        await checkFollowStatus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFollowing
                  ? 'You are now following ${widget.username}'
                  : 'You unfollowed ${widget.username}',
            ),
          ),
        );
      } else {
        // Revert if failed
        setState(() {
          isFollowing = !isFollowing;
        });
        throw Exception(response.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          isFollowLoading = false;
        });
      }
    }
  }

  Future<void> fetchFollowerStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/user-stats/${widget.username}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          followersCount = responseData['followersCount'] ?? 0;
          followingCount = responseData['followingCount'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching follower stats: $e');
    }
  }

  void _showFollowList(BuildContext context, bool showFollowers) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FollowersListScreen(
              token: widget.token,
              username: widget.username,
              showFollowers: showFollowers,
            ),
      ),
    );
  }

  Widget buildExpandableSection(
    String title,
    List<String> items,
    IconData icon,
  ) {
    final isCollapsed = collapsedSections[title] ?? true;
    final isExpanded = expandedSections[title] ?? false;
    final displayedItems = isExpanded ? items : items.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
              const SizedBox(height: 12),
              if (displayedItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "No $title available",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...displayedItems.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          expandedSections[title] = !isExpanded;
                        });
                      },
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Theme.of(context).primaryColor,
                      ),
                      label: Text(
                        isExpanded
                            ? "Show Less"
                            : "Show More (${items.length - 3} more)",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCountWidget(int count, String label, bool isFollowers) {
    return GestureDetector(
      onTap: () => _showFollowList(context, isFollowers),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : userData == null
                ? const Center(child: Text('User not found'))
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Header Section
                      Container(
                        decoration: BoxDecoration(
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
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Back Button
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back_ios_new,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Profile',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    const SizedBox(
                                      width: 48,
                                    ), // Balance the back button
                                  ],
                                ),
                                const SizedBox(height: 32),
                                // Avatar and Name
                                Hero(
                                  tag: 'profile-avatar-${widget.username}',

                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 56,
                                        backgroundImage:
                                            uploadedImageUrl != null &&
                                                    uploadedImageUrl!.isNotEmpty
                                                ? NetworkImage(
                                                  uploadedImageUrl!,
                                                )
                                                : const AssetImage(
                                                      'assets/images/default_avatar.png',
                                                    )
                                                    as ImageProvider,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  fullName ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '@${widget.username}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildCountWidget(
                                      followersCount,
                                      'Followers',
                                      true,
                                    ),
                                    const SizedBox(width: 24),
                                    _buildCountWidget(
                                      followingCount,
                                      'Following',
                                      false,
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        final username = widget.username;

                                        if (username != null) {
                                          final cvUrl =
                                              await ApplicationService.getUserCvByUsername(
                                                username,
                                              );
                                          if (cvUrl != null &&
                                              cvUrl.isNotEmpty) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => PDFViewerPage(
                                                      url: cvUrl,
                                                    ),
                                              ),
                                            );
                                          } else {
                                            print('No CV URL found');
                                          }
                                        } else {
                                          print("application.userId is null!");
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            Theme.of(context).primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text(
                                        "View Cv",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Follow Button
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient:
                                        isFollowing
                                            ? null
                                            : LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white,
                                                Colors.white.withOpacity(0.9),
                                              ],
                                            ),
                                    color:
                                        isFollowing
                                            ? Colors.white.withOpacity(0.2)
                                            : null,
                                    border:
                                        isFollowing
                                            ? Border.all(
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              width: 2,
                                            )
                                            : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap:
                                          isFollowLoading ? null : toggleFollow,
                                      child: Center(
                                        child:
                                            isFollowLoading
                                                ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          isFollowing
                                                              ? Colors.white
                                                              : Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                        ),
                                                  ),
                                                )
                                                : Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isFollowing
                                                          ? Icons.person_remove
                                                          : Icons.person_add,
                                                      color:
                                                          isFollowing
                                                              ? Colors.white
                                                              : Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                      size: 22,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      isFollowing
                                                          ? 'Unfollow'
                                                          : 'Follow',
                                                      style: TextStyle(
                                                        color:
                                                            isFollowing
                                                                ? Colors.white
                                                                : Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Summary Section
                      if (userProfileData != null) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.08),
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                userProfileData!.summary.isNotEmpty
                                    ? Text(
                                      userProfileData!.summary,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        height: 1.6,
                                      ),
                                    )
                                    : Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.grey[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "No summary provided",
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      // Profile Sections
                      if (userProfileData != null) ...[
                        buildExpandableSection(
                          "Education",
                          userProfileData!.education,
                          Icons.school_outlined,
                        ),
                        buildExpandableSection(
                          "Skills",
                          userProfileData!.skills,
                          Icons.star_outline,
                        ),
                        buildExpandableSection(
                          "Experience",
                          userProfileData!.experience,
                          Icons.work_outline,
                        ),
                        buildExpandableSection(
                          "Certifications",
                          userProfileData!.certifications,
                          Icons.verified_outlined,
                        ),
                        buildExpandableSection(
                          "Languages",
                          userProfileData!.languages,
                          Icons.language_outlined,
                        ),
                      ],
                      // Posts Section
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.08),
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
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.article_outlined,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Posts (${userPosts.length})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (userPosts.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.article_outlined,
                                          color: Colors.grey[400],
                                          size: 48,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No posts yet',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${fullName ?? widget.username} hasn\'t shared any posts',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children:
                                      userPosts.map((post) {
                                        final authorName =
                                            fullName ?? 'Unknown Author';
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          child: PostCard(
                                            postId: post['id'],
                                            postText: post['text'],
                                            authorName: authorName,
                                            timestamp: post['time'],
                                            authorAvatarUrl:
                                                post['avatarUrl'] ?? '',
                                            isOwner: false,
                                            isLiked: post['isLiked'] ?? false,
                                            likeCount: post['likeCount'] ?? 0,
                                            onLike: () async {
                                              try {
                                                setState(() {
                                                  post['isLiked'] =
                                                      !(post['isLiked'] ??
                                                          false);
                                                  if (post['isLiked']) {
                                                    post['likeCount'] =
                                                        (post['likeCount'] ??
                                                            0) +
                                                        1;
                                                  } else {
                                                    post['likeCount'] =
                                                        (post['likeCount'] ??
                                                            1) -
                                                        1;
                                                  }
                                                });
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Failed to like post: $e',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            onComment: () {},
                                            currentUserAvatar:
                                                userData?['avatarUrl'] ?? '',
                                            currentUserName:
                                                userData?['username'] ?? '',
                                            token: widget.token,
                                            initialComments:
                                                List<Map<String, dynamic>>.from(
                                                  (post['comments'] ?? []).map(
                                                    (c) => {
                                                      '_id': c['_id'],
                                                      'text': c['text'],
                                                      'author': c['author'],
                                                      'avatarUrl':
                                                          c['avatarUrl'],
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
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      ),
    );
  }
}
