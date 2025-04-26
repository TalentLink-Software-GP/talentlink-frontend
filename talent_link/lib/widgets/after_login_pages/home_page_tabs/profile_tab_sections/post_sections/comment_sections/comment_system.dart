// import 'package:flutter/material.dart';
// import 'comment_widget.dart';
// import 'reply/reply_input_widget.dart';

// import 'package:flutter/material.dart';

// class CommentSystem extends StatefulWidget {
//   final List<Map<String, dynamic>> initialComments;
//   final String authorName;
//   final String authorAvatarUrl;
//   final Function(String)? onCommentAdded;

//   const CommentSystem({
//     super.key,
//     required this.initialComments,
//     required this.authorName,
//     required this.authorAvatarUrl,
//     this.onCommentAdded,
//   });

//   @override
//   State<CommentSystem> createState() => _CommentSystemState();
// }

// class _CommentSystemState extends State<CommentSystem> {
//   late List<Map<String, dynamic>> comments;
//   final TextEditingController _commentController = TextEditingController();
//   int? _replyingToCommentIndex;

//   @override
//   void initState() {
//     super.initState();
//     comments = widget.initialComments;
//   }

//   void _submitComment() {
//     if (_commentController.text.trim().isEmpty) return;

//     setState(() {
//       if (_replyingToCommentIndex != null) {
//         // Add reply to the specific comment
//         if (comments[_replyingToCommentIndex!]['replies'] == null) {
//           comments[_replyingToCommentIndex!]['replies'] = [];
//         }
//         comments[_replyingToCommentIndex!]['replies'].add({
//           'text': _commentController.text,
//           'author': widget.authorName,
//           'time': DateTime.now(),
//         });
//       } else {
//         // Add new top-level comment
//         comments.add({
//           'text': _commentController.text,
//           'author': widget.authorName,
//           'time': DateTime.now(),
//           'replies': [],
//         });
//       }
//       _commentController.clear();
//       _replyingToCommentIndex = null;

//       if (widget.onCommentAdded != null) {
//         widget.onCommentAdded!(_commentController.text);
//       }
//     });
//   }

//   void _startReply(int commentIndex) {
//     setState(() {
//       _replyingToCommentIndex = commentIndex;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Display existing comments
//         if (comments.isNotEmpty)
//           ...comments.asMap().entries.map((commentEntry) {
//             return Column(
//               children: [
//                 CommentWidget(
//                   comment: commentEntry.value,
//                   authorAvatarUrl: widget.authorAvatarUrl,
//                   onReply: () => _startReply(commentEntry.key),
//                 ),

//                 // Display replies
//                 if (commentEntry.value['replies'] != null &&
//                     commentEntry.value['replies'].isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 40.0),
//                     child: Column(
//                       children:
//                           (commentEntry.value['replies'] as List).map((reply) {
//                             return ReplyWidget(
//                               reply: reply,
//                               authorAvatarUrl: widget.authorAvatarUrl,
//                             );
//                           }).toList(),
//                     ),
//                   ),

//                 // Reply input field (when actively replying)
//                 if (_replyingToCommentIndex == commentEntry.key)
//                   ReplyInputField(
//                     controller: _commentController,
//                     onSubmit: _submitComment,
//                     isReply: true,
//                   ),
//               ],
//             );
//           }).toList(),

//         // New comment input (for top-level comments)
//         CommentInputField(
//           controller: _commentController,
//           onSubmit: _submitComment,
//           isReply: false,
//         ),
//       ],
//     );
//   }
// }
