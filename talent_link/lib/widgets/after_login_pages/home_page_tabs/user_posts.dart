import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

class PostCreator extends StatefulWidget {
  final String token;

  const PostCreator({super.key, required this.token});

  @override
  State<PostCreator> createState() => _PostCreatorState();
}

class _PostCreatorState extends State<PostCreator> {
  final TextEditingController _postController = TextEditingController();
  String? uploadedImageUrl;
  String? fullName;
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    String username = decodedToken['username'];

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/users/getUserData?userName=$username',
        ),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          uploadedImageUrl = data['avatarUrl'];
          fullName = data['name'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<bool> savingPost(String author, String content) async {
    const url = 'http://10.0.2.2:5000/api/posts/createPost';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"author": author, "content": content}),
    );
    return response.statusCode == 201;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      uploadedImageUrl != null
                          ? NetworkImage(uploadedImageUrl!)
                          : const NetworkImage(
                            'https://randomuser.me/api/portraits/men/1.jpg',
                          ),
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _postController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "What’s on your mind, ${fullName ?? '...'}?",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  final text = _postController.text.trim();
                  if (text.isNotEmpty && fullName != null) {
                    final success = await savingPost(fullName!, text);
                    if (success) {
                      setState(() {
                        posts.add({
                          'text': text,
                          'author': fullName!,
                          'time': DateTime.now(),
                        });
                      });
                      _postController.clear();
                    }
                  }
                },
                child: const Text("Post"),
              ),
            ),
            const SizedBox(height: 10),
            ...posts.map(
              (post) => PostCard(
                postText: post['text'],
                authorName: post['author'],
                timestamp: post['time'],
                currentUserName: fullName ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String postText;
  final String authorName;
  final DateTime timestamp;
  final String currentUserName;

  const PostCard({
    super.key,
    required this.postText,
    required this.authorName,
    required this.timestamp,
    required this.currentUserName,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int likeCount = 0;
  bool isLiked = false;
  List<Map<String, dynamic>> comments = [];
  final TextEditingController commentController = TextEditingController();

  void _showCommentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final replies = comment['replies'] as List<dynamic>;
                        final visibleReplies =
                            replies.length <= 2
                                ? replies
                                : replies.sublist(replies.length - 2);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: const CircleAvatar(
                                backgroundImage: NetworkImage(
                                  'https://randomuser.me/api/portraits/men/1.jpg',
                                ),
                              ),
                              title: Text(comment['author']),
                              subtitle: Text(comment['text']),
                              trailing: TextButton(
                                onPressed:
                                    () =>
                                        _showReplyDialog(index, setModalState),
                                child: const Text("Reply"),
                              ),
                            ),
                            if (replies.length > 2)
                              Padding(
                                padding: const EdgeInsets.only(left: 40),
                                child: TextButton(
                                  onPressed:
                                      () => _showReplyDialog(
                                        index,
                                        setModalState,
                                      ),
                                  child: Text(
                                    'View all ${replies.length} replies',
                                  ),
                                ),
                              ),
                            ...visibleReplies.map<Widget>((reply) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 40,
                                  bottom: 6,
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    radius: 15,
                                    backgroundImage: NetworkImage(
                                      'https://randomuser.me/api/portraits/women/1.jpg',
                                    ),
                                  ),
                                  title: Text(reply['author']),
                                  subtitle: Text(reply['text']),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: const InputDecoration(
                              hintText: "Write a comment...",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (commentController.text.trim().isNotEmpty) {
                              setModalState(() {
                                comments.add({
                                  'text': commentController.text.trim(),
                                  'author': widget.currentUserName,
                                  'replies': [],
                                });
                                commentController.clear();
                              });
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReplyDialog(int commentIndex, StateSetter setModalState) {
    TextEditingController replyController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Reply to comment"),
            content: TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: "Write your reply...",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final replyText = replyController.text.trim();
                  if (replyText.isNotEmpty) {
                    setModalState(() {
                      comments[commentIndex]['replies'].add({
                        'text': replyText,
                        'author': widget.currentUserName,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Send"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleComments =
        comments.length <= 2 ? comments : comments.sublist(comments.length - 2);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/men/1.jpg',
                  ),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _timeAgo(widget.timestamp),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.postText),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isLiked = !isLiked;
                      likeCount += isLiked ? 1 : -1;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: isLiked ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text('Like ($likeCount)'),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _showCommentModal(context),
                  child: const Row(
                    children: [
                      Icon(Icons.comment_outlined),
                      SizedBox(width: 4),
                      Text('Comment'),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.share_outlined),
                    SizedBox(width: 4),
                    Text('Share'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (comments.length > 2)
              TextButton(
                onPressed: () => _showCommentModal(context),
                child: Text('View all ${comments.length} comments'),
              ),
            ...visibleComments.map(
              (comment) => Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/men/1.jpg',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment['author'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(comment['text']),
                          ),
                          TextButton(
                            onPressed:
                                () => _showReplyDialog(
                                  comments.indexOf(comment),
                                  (s) => setState(() {}),
                                ),
                            child: const Text(
                              "Reply",
                              style: TextStyle(fontSize: 12),
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
    return '${date.day}/${date.month}/${date.year}';
  }
}
