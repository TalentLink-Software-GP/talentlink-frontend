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
  String? name;
  List<String> posts = []; // List to store created posts

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
      print(username);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          uploadedImageUrl = data['avatarUrl'];
          String firstName = data['name'];
          List<String> nameParts = firstName.split(' ');
          name = nameParts[0];
        });
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
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
                      hintText: "What’s on your mind, $name?",
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
                  if (text.isNotEmpty) {
                    final success = await savingPost(name!, text);
                    if (success) {
                      setState(() {
                        posts.add(text); // Add the new post to the list
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post created successfully'),
                        ),
                      );
                      _postController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to create post')),
                      );
                    }
                  }
                },
                child: const Text("Post"),
              ),
            ),
            const SizedBox(height: 10),
            ...posts
                .map((post) => PostCard(postText: post))
                .toList(), // Display posts dynamically
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String postText;
  const PostCard({super.key, required this.postText});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int likeCount = 0;
  bool isLiked = false;
  bool showCommentField = false;
  final TextEditingController commentController = TextEditingController();
  List<String> comments = [];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/men/1.jpg',
                  ),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Text("Ahmed", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onTap: () {
                    setState(() {
                      showCommentField = !showCommentField;
                    });
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.comment_outlined),
                      SizedBox(width: 4),
                      Text('Comment'),
                    ],
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.share_outlined),
                    SizedBox(width: 4),
                    Text('Share'),
                  ],
                ),
              ],
            ),

            if (showCommentField) ...[
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      comments.add(value.trim());
                      commentController.clear();
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),
            ...comments.map(
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
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          comment,
                          style: const TextStyle(fontSize: 14),
                        ),
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
}
