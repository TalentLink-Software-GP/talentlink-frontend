import 'package:flutter/material.dart';

class commentInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function(String) onSubmit;
  final bool isReplyingToComment;
  final String hintText;
  final String? commentId;
  final VoidCallback? onTap;

  const commentInputWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.commentId,
    this.isReplyingToComment = false,
    this.hintText = "Write a comment...",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isReplyingToComment ? 40.0 : 0,
        top: 12.0,
        bottom: 8.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                ),
                onTap: onTap,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  await onSubmit(text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
