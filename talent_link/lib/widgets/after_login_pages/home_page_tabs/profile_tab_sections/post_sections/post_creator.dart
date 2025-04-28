import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/comment_sections/comments_modal.dart';

import './post_card.dart';
import './post_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:talent_link/services/post_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PostCreator extends StatefulWidget {
  final String token;

  const PostCreator({super.key, required this.token});

  @override
  State<PostCreator> createState() => _PostCreatorState();
}

class _PostCreatorState extends State<PostCreator> {
  final TextEditingController _postController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late PostService _postService;
  String? uploadedImageUrl;
  String? fullName;
  String? username;
  List<Map<String, dynamic>> posts = [];
  int _page = 1;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _postService = PostService(widget.token);
    fetchUserData();
    fetchPosts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      fetchPosts();
    }
  }

  Future<void> fetchPosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await _postService.fetchPosts(_page, _limit);
      final List<dynamic> data = response['posts'];

      setState(() {
        _page++;
        _hasMore = data.length == _limit;

        posts.addAll(
          data.map(
            (post) => {
              'text': post['content'],
              'author': post['author'],
              'time': DateTime.parse(post['createdAt']),
              'avatarUrl': post['avatarUrl'] ?? '',
              'id': post['_id'],
              'isLiked': post['isLiked'] ?? false,
              'likeCount': post['likeCount'] ?? 0,
              'isOwner': post['isOwner'] ?? false,
              'comments': List<Map<String, dynamic>>.from(
                post['comments']?.map(
                      (c) => {
                        '_id': c['_id'],
                        'text': c['text'],
                        'author': c['author'],
                        'avatarUrl': c['avatarUrl'],
                        'replies': List<Map<String, dynamic>>.from(
                          c['replies'] ?? [],
                        ),
                      },
                    ) ??
                    [],
              ),
            },
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching posts: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchUserData() async {
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
      username = decodedToken['username'];
      final data = await _postService.fetchUserData();
      setState(() {
        uploadedImageUrl = data['avatarUrl'];
        fullName = data['name'];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching user data: $e')));
    }
  }

  Future<void> createPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty || fullName == null) return;

    try {
      final success = await _postService.createPost(text);
      if (success) {
        _postController.clear();
        setState(() {
          _page = 1;
          posts.clear();
          _hasMore = true;
        });
        await fetchPosts();
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
    }
  }

  Future<void> _handlePostUpdated(int index, String newText) async {
    final postId = posts[index]['id'];
    try {
      final success = await _postService.updatePost(postId, newText);
      if (success) {
        setState(() {
          posts[index]['text'] = newText;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update post: $e')));
    }
  }

  Future<void> _handlePostDeleted(int index) async {
    final postId = posts[index]['id'];
    try {
      final success = await _postService.deletePost(postId);
      if (success) {
        setState(() {
          posts.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
    }
  }

  void _handlePostLiked(int index) {
    setState(() {
      posts[index]['isLiked'] = !posts[index]['isLiked'];
      if (posts[index]['isLiked']) {
        posts[index]['likeCount']++;
      } else {
        posts[index]['likeCount']--;
      }
    });
  }

  void _handleShowComments(int postIndex) async {
    final post = posts[postIndex];
    final String postId = post['id'];

    if (post['comments'] == null) {
      post['comments'] = [];
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => CommentsModal(
            comments: List<Map<String, dynamic>>.from(post['comments']),
            currentUserAvatar: uploadedImageUrl ?? '',
            currentUserName: fullName ?? 'Anonymous',
            postId: postId,
            token: widget.token,
          ),
    );

    if (mounted) setState(() {});
  }

  Future<void> fetchPostAuthors() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await _postService.fetchPosts(_page, _limit);
      final List<dynamic> data = response['posts'];

      setState(() {
        _page++;
        _hasMore = data.length == _limit;

        posts.addAll(
          data.map((post) => {'authorUsername': post['author']['username']}),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching post authors: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
              child: Column(
                children: [
                  PostInputWidget(
                    controller: _postController,
                    onPost: createPost,
                    fullName: fullName,
                    avatarUrl: uploadedImageUrl,
                  ),
                  const SizedBox(height: 10),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),
                  ...posts.asMap().entries.map((entry) {
                    final post = entry.value;
                    return PostCard(
                      postText: post['text'],
                      authorName:
                          post['author'] is Map<String, dynamic>
                              ? post['author']['fullName'] ?? 'Unknown'
                              : post['author'],
                      timestamp: post['time'],
                      authorAvatarUrl: post['avatarUrl'],
                      postId: post['id'],
                      onDelete: () => _handlePostDeleted(entry.key),
                      onUpdate:
                          (newText) => _handlePostUpdated(entry.key, newText),
                      isOwner: post['isOwner'],
                      isLiked: post['isLiked'],
                      likeCount: post['likeCount'],
                      onLike: () => _handlePostLiked(entry.key),
                      onComment: () => _handleShowComments(entry.key),
                      currentUserAvatar: uploadedImageUrl ?? '',
                      currentUserName: fullName ?? 'Anonymous',
                      token: widget.token,
                      username: post['author'] ?? '',

                      initialComments: List<Map<String, dynamic>>.from(
                        post['comments']?.map(
                              (c) => {
                                '_id': c['_id'],
                                'text': c['text'],
                                'author': c['author'],
                                'avatarUrl': c['avatarUrl'],
                                'replies': List<Map<String, dynamic>>.from(
                                  c['replies'] ?? [],
                                ),
                              },
                            ) ??
                            [],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
