import 'package:flutter/material.dart';
import 'package:talent_link/services/post_service.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/post_card.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
  late PostService _postService;
  late PostCard _postCardState;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> userPosts = [];
  bool _isLoading = true;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  String? username;
  String? uploadedImageUrl;
  String? fullName;

  @override
  void initState() {
    super.initState();
    _postService = PostService(widget.token);
    fetchUserDataAndPosts();
  }

  Future<void> fetchUserDataAndPosts() async {
    try {
      // 1. Fetch user data using fetchUserData()
      final userResponse = await _postService.fetchUserByUsername(
        widget.username,
      );

      // 2. Fetch posts using fetchPosts()
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

        _hasMore = postsResponse.length == _limit;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.username}\'s Profile')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : userData == null
              ? const Center(child: Text('User not found'))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          uploadedImageUrl != null &&
                                  uploadedImageUrl!.isNotEmpty
                              ? NetworkImage(uploadedImageUrl!)
                              : const AssetImage(
                                    'assets/images/default_avatar.png',
                                  )
                                  as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      fullName ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${widget.username}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
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
                                  currentUserName: userData?['username'] ?? '',
                                  token: widget.token,
                                  initialComments:
                                      List<Map<String, dynamic>>.from(
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
