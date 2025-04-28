import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/ProfileWidgetForAnotherUsers%20.dart';
import 'comment_sections/comments_modal.dart';
import 'comment_sections/comments_section.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostCard extends StatefulWidget {
  final String postId;
  final String postText;
  final String authorName;
  final DateTime timestamp;
  final String authorAvatarUrl;
  final VoidCallback? onDelete;
  final Function(String)? onUpdate;
  final bool isOwner;
  final bool isLiked;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final List<Map<String, dynamic>> initialComments;
  final String currentUserAvatar;
  final String currentUserName;
  final String token;
  final String username;
  final GlobalKey<_PostCardState> _key;

  void handleLike() {
    _key.currentState?.handleLike();
  }

  PostCard({
    Key? key,
    required this.postText,
    required this.authorName,
    required this.timestamp,
    required this.authorAvatarUrl,
    required this.postId,
    this.onDelete,
    this.onUpdate,
    required this.isOwner,
    required this.isLiked,
    required this.likeCount,
    required this.onLike,
    required this.onComment,
    required this.currentUserAvatar,
    required this.currentUserName,
    required this.token,
    this.initialComments = const [],
    required this.username,
  }) : _key = GlobalKey<_PostCardState>(),
       super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late List<Map<String, dynamic>> comments;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    comments = widget.initialComments;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _showCommentModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => CommentsModal(
            comments: comments,
            currentUserAvatar: widget.currentUserAvatar,
            currentUserName: widget.currentUserName,
            postId: widget.postId,
            token: widget.token,
          ),
    );

    if (mounted) setState(() {});
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isOwner)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Post'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog();
                  },
                ),
              if (widget.isOwner)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Post',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete();
                  },
                ),
            ],
          ),
    );
  }

  void _showEditDialog() {
    final controller = TextEditingController(text: widget.postText);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Post'),
            content: TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onUpdate!(controller.text);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Post?'),
            content: const Text('This action cannot be undone'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onDelete!();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
  //      'http://10.0.2.2:5000/api/posts/${widget.postId}/like-post',

  Future<void> handleLike() async {
    final url = Uri.parse(
      'http://10.0.2.2:5000/api/posts/${widget.postId}/like-post',
    );

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({'isLiked': !widget.isLiked}),
      );

      if (response.statusCode == 200) {
        widget.onLike();
      } else {
        print('Failed to like the post: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while liking the post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, right: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(173, 197, 162, 67).withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(10, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.pinkAccent.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.authorAvatarUrl.isNotEmpty
                          ? widget.authorAvatarUrl
                          : 'https://randomuser.me/api/portraits/men/1.jpg',
                    ),
                    radius: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        print("username: ${widget.username}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProfileWidgetForAnotherUsers(
                                  username: widget.username,
                                  token: widget.token, // user
                                ),
                          ),
                        );
                      },
                      child: Text(
                        widget.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      _timeAgo(widget.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Spacer(),
                if (widget.isOwner)
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: _showPostOptions,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Post Content
            Text(
              widget.postText,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Like Count
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: handleLike,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          widget.isLiked
                              ? Colors.red.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isLiked ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.likeCount}',
                          style: TextStyle(
                            color: widget.isLiked ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            /////here
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: handleLike,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          widget.isLiked
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isLiked ? Colors.red : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.isLiked ? 'Loved' : 'Love',
                          style: TextStyle(
                            color: widget.isLiked ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: _showCommentModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.comment_outlined, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Comment',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.share_outlined, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Share',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Comments Section
            CommentsSection(
              comments: comments.take(2).toList(),
              currentUserAvatar: widget.currentUserAvatar,
              currentUserName: widget.currentUserName,
              postId: widget.postId, // <<< ADD THIS
              token: widget.token,
              onCommentAdded: (newComment) async {
                setState(() => comments.add(newComment));
              },
              onReplyAdded: (commentIndex, newReply) async {
                setState(() {
                  comments[commentIndex]['replies'] ??= [];
                  comments[commentIndex]['replies'].add(newReply);
                });
              },
            ),

            // View all comments button
            if (comments.length > 2)
              Center(
                child: TextButton(
                  onPressed: _showCommentModal,
                  child: Text(
                    'View all ${comments.length} comments',
                    style: const TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
