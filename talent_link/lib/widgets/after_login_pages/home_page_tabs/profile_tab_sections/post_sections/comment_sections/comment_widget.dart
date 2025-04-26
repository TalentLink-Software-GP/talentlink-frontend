import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  final String author;
  final String text;
  final String avatarUrl;
  final bool isMainComment;
  final VoidCallback? onReply;

  const CommentWidget({
    super.key,
    required this.author,
    required this.text,
    required this.avatarUrl,
    this.isMainComment = true,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: (isMainComment ? Colors.blueAccent : Colors.greenAccent)
                  .withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: CircleAvatar(
            radius: isMainComment ? 15 : 12,
            backgroundImage: NetworkImage(
              avatarUrl.isNotEmpty
                  ? avatarUrl
                  : 'https://randomuser.me/api/portraits/men/1.jpg',
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMainComment ? 14 : 12,
                ),
              ),
              Text(text, style: TextStyle(fontSize: isMainComment ? null : 12)),
              if (onReply != null && isMainComment)
                TextButton(
                  onPressed: onReply,
                  child: const Text(
                    "Reply",
                    style: TextStyle(fontSize: 12, color: Colors.purpleAccent),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
