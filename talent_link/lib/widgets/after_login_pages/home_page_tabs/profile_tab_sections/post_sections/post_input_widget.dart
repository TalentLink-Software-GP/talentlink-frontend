import 'package:flutter/material.dart';

class PostInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? fullName;
  final String? avatarUrl;
  final VoidCallback onPost;

  const PostInputWidget({
    super.key,
    required this.controller,
    required this.onPost,
    this.fullName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purpleAccent, width: 2),
              ),
              child: CircleAvatar(
                backgroundImage:
                    avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : const NetworkImage(
                          'https://randomuser.me/api/portraits/men/1.jpg',
                        ),
                radius: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: "What's on your mind, ${fullName ?? '...'}?",
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 7, 133, 18),
                  Color.fromARGB(255, 215, 255, 236),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Post",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
