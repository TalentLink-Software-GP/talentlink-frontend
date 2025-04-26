import 'package:flutter/material.dart';
import 'comments_section.dart';
import 'comment_service.dart';

class CommentsModal extends StatefulWidget {
  final List<Map<String, dynamic>> comments;
  final String currentUserAvatar;
  final String currentUserName;
  final String postId;
  final String token;

  const CommentsModal({
    super.key,
    required this.comments,
    required this.currentUserAvatar,
    required this.currentUserName,
    required this.postId,
    required this.token,
  });

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  late CommentService _commentService;
  late CommentService _replyService;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _commentService = CommentService(
      baseUrl: "http://10.0.2.2:5000/api",
      token: widget.token,
      postId: widget.postId,
    );
    _replyService = CommentService(
      baseUrl: "http://10.0.2.2:5000/api",
      token: widget.token,
      postId: widget.postId,
    );
  }

  Future<void> _handleCommentAdded(Map<String, dynamic> newComment) async {
    final text = newComment['text']?.toString().trim();
    if (text == null || text.isEmpty) {
      throw Exception('Comment text cannot be empty');
    }

    setState(() => _isLoading = true);
    try {
      final result = await _commentService.addComment(text);
      if (mounted) {
        setState(() {
          widget.comments.add({
            '_id': result['_id'] ?? result['comment']?['_id'],
            'text': result['text'] ?? result['comment']?['text'] ?? text,
            'author': widget.currentUserName,
            'avatarUrl': widget.currentUserAvatar,
            'replies': [],
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleReplyAdded(
    int commentIndex,
    Map<String, dynamic> newReply,
  ) async {
    final text = newReply['text']?.toString().trim();
    if (text == null || text.isEmpty) {
      throw Exception('Reply text cannot be empty');
    }

    final commentId = widget.comments[commentIndex]['_id'];
    setState(() => _isLoading = true);
    try {
      final result = await _replyService.addReply(commentId, text);

      if (mounted) {
        setState(() {
          widget.comments[commentIndex]['replies'] ??= [];
          widget.comments[commentIndex]['replies'].add({
            '_id': result['_id'] ?? result['reply']?['_id'],
            'text': result['text'] ?? result['reply']?['text'] ?? text,
            'author': widget.currentUserName,
            'avatarUrl': widget.currentUserAvatar,
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add reply: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      // ... keep existing builder ...
      builder: (context, scrollController) {
        return Stack(
          children: [
            // ... existing container ...
            CommentsSection(
              comments: widget.comments,
              currentUserAvatar: widget.currentUserAvatar,
              currentUserName: widget.currentUserName,
              postId: widget.postId, // <<< ADD THIS
              token: widget.token,
              onCommentAdded: (newComment) async {
                setState(() => _isLoading = true);
                try {
                  await _handleCommentAdded(newComment);
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              onReplyAdded: (commentIndex, newReply) async {
                setState(() => _isLoading = true);
                try {
                  await _handleReplyAdded(commentIndex, newReply);
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }
}
