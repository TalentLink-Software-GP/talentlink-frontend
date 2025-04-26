// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'dart:convert';

// class PostCreator extends StatefulWidget {
//   final String token;

//   const PostCreator({super.key, required this.token});

//   @override
//   State<PostCreator> createState() => _PostCreatorState();
// }

// class _PostCreatorState extends State<PostCreator> {
//   final TextEditingController _postController = TextEditingController();
//   String? uploadedImageUrl;
//   String? fullName;
//   String? username;
//   List<Map<String, dynamic>> posts = [];
//   final ScrollController _scrollController = ScrollController();
//   int _page = 1;
//   final int _limit = 10;
//   bool _isLoading = false;
//   bool _hasMore = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//     fetchPosts();
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent - 200) {
//         fetchPosts();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchPosts() async {
//     if (_isLoading || !_hasMore) return;

//     setState(() => _isLoading = true);

//     final response = await http.get(
//       Uri.parse(
//         'http://10.0.2.2:5000/api/posts/get-posts?page=$_page&limit=$_limit',
//       ),
//       headers: {'Authorization': widget.token},
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> responseData = jsonDecode(response.body);
//       Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
//       String currentUsername = decodedToken['username'];

//       final List<dynamic> data = responseData['posts'];
//       setState(() {
//         _page++;
//         _hasMore = data.length == _limit;

//         posts.addAll(
//           data.map(
//             (post) => {
//               'text': post['content'],
//               'author': post['author'], // This should be full name from backend
//               'time': DateTime.parse(post['createdAt']),
//               'avatarUrl': post['avatarUrl'] ?? '',
//               'id': post['_id'],
//               'isLiked': false,
//               'likeCount': 0,
//               'isOwner': post['isOwner'] ?? false, // Ensure boolean
//             },
//           ),
//         );
//       });
//     }

//     setState(() => _isLoading = false);
//   }

//   Future<void> fetchUserData() async {
//     Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
//     username = decodedToken['username'];

//     try {
//       final response = await http.get(
//         Uri.parse(
//           'http://10.0.2.2:5000/api/users/getUserData?userName=$username',
//         ),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': widget.token,
//         },
//       );
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           uploadedImageUrl = data['avatarUrl'];
//           fullName = data['name'];
//         });
//       }
//     } catch (e) {
//       print('Error fetching user data: $e');
//     }
//   }

//   Future<bool> savingPost(String author, String content) async {
//     const url = 'http://10.0.2.2:5000/api/posts/createPost';
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': widget.token,
//         },
//         body: jsonEncode({"content": content}),
//       );

//       if (response.statusCode == 201) {
//         setState(() {
//           _page = 1;
//           posts.clear();
//         });
//         await fetchPosts();

//         return true;
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to create post: ${response.body}')),
//         );
//         return false;
//       }
//     } catch (e) {
//       print('Error creating post: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
//       return false;
//     }
//   }

//   Future<bool> updatePost(String postId, String newContent) async {
//     final url = 'http://10.0.2.2:5000/api/posts/updatePost/$postId';
//     final response = await http.put(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': widget.token,
//       },
//       body: jsonEncode({"content": newContent}),
//     );

//     return response.statusCode == 200;
//   }

//   Future<bool> deletePost(String postId) async {
//     final url = 'http://10.0.2.2:5000/api/posts/deletePost/$postId';
//     final response = await http.delete(
//       Uri.parse(url),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': widget.token,
//       },
//     );

//     return response.statusCode == 200;
//   }

//   void _handlePostUpdated(int index, String newText) async {
//     final postId = posts[index]['id'];
//     final success = await updatePost(postId, newText);
//     if (success) {
//       setState(() {
//         posts[index]['text'] = newText;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Post updated successfully')),
//       );
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Failed to update post')));
//     }
//   }

//   void _handlePostDeleted(int index) async {
//     final postId = posts[index]['id'];
//     final success = await deletePost(postId);
//     if (success) {
//       setState(() {
//         posts.removeAt(index);
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Post deleted successfully')),
//       );
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Failed to delete post')));
//     }
//   }

//   void _handlePostLiked(int index) {
//     setState(() {
//       posts[index]['isLiked'] = !posts[index]['isLiked'];
//       if (posts[index]['isLiked']) {
//         posts[index]['likeCount']++;
//       } else {
//         posts[index]['likeCount']--;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         controller: _scrollController,
//         physics: const BouncingScrollPhysics(),
//         child: Container(
//           margin: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 spreadRadius: 3,
//                 blurRadius: 10,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: Colors.purpleAccent,
//                             width: 2,
//                           ),
//                         ),
//                         child: CircleAvatar(
//                           backgroundImage:
//                               uploadedImageUrl != null
//                                   ? NetworkImage(uploadedImageUrl!)
//                                   : const NetworkImage(
//                                     'https://randomuser.me/api/portraits/men/1.jpg',
//                                   ),
//                           radius: 22,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[50],
//                             borderRadius: BorderRadius.circular(30),
//                             border: Border.all(
//                               color: Colors.grey.withOpacity(0.2),
//                             ),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: TextField(
//                               controller: _postController,
//                               maxLines: null,
//                               style: const TextStyle(
//                                 fontSize: 15,
//                                 color: Colors.black87,
//                               ),
//                               decoration: InputDecoration(
//                                 hintText:
//                                     "What's on your mind, ${fullName ?? '...'}?",
//                                 hintStyle: TextStyle(
//                                   color: Colors.grey[500],
//                                   fontSize: 15,
//                                 ),
//                                 border: InputBorder.none,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [
//                             Color.fromARGB(255, 7, 133, 18),
//                             Color.fromARGB(255, 215, 255, 236),
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(30),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.purple.withOpacity(0.3),
//                             spreadRadius: 1,
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           final text = _postController.text.trim();
//                           if (text.isNotEmpty && fullName != null) {
//                             final success = await savingPost(fullName!, text);
//                             if (success) {
//                               _postController.clear();
//                               _scrollController.animateTo(
//                                 0,
//                                 duration: const Duration(milliseconds: 300),
//                                 curve: Curves.easeOut,
//                               );
//                             }
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           shadowColor: Colors.transparent,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 24,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                         ),
//                         child: const Text(
//                           "Post",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   if (_isLoading)
//                     const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 20),
//                       child: CircularProgressIndicator(),
//                     ),

//                   ...posts.asMap().entries.map(
//                     (entry) => PostCard(
//                       postText: entry.value['text'],
//                       authorName: entry.value['author'],
//                       timestamp: entry.value['time'],
//                       authorAvatarUrl: entry.value['avatarUrl'],
//                       postId: entry.value['id'],
//                       onDelete: () => _handlePostDeleted(entry.key),
//                       onUpdate:
//                           (newText) => _handlePostUpdated(entry.key, newText),
//                       isOwner:
//                           entry.value['isOwner'], // This is now properly set
//                       isLiked: entry.value['isLiked'],
//                       likeCount: entry.value['likeCount'],
//                       onLike: () => _handlePostLiked(entry.key),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PostCard extends StatefulWidget {
//   final String postText;
//   final String authorName;
//   final DateTime timestamp;
//   final String authorAvatarUrl;
//   final String postId;
//   final VoidCallback onDelete;
//   final Function(String) onUpdate;
//   final bool isOwner;
//   final bool isLiked;
//   final int likeCount;
//   final VoidCallback onLike;

//   const PostCard({
//     super.key,
//     required this.postText,
//     required this.authorName,
//     required this.timestamp,
//     required this.authorAvatarUrl,
//     required this.postId,
//     required this.onDelete,
//     required this.onUpdate,
//     required this.isOwner,
//     required this.isLiked,
//     required this.likeCount,
//     required this.onLike,
//   });

//   @override
//   State<PostCard> createState() => _PostCardState();
// }

// class _PostCardState extends State<PostCard> {
//   List<Map<String, dynamic>> comments = [];
//   final TextEditingController commentController = TextEditingController();

//   void _showPostOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (widget.isOwner)
//               ListTile(
//                 leading: const Icon(Icons.edit),
//                 title: const Text('Edit Post'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _showEditDialog();
//                 },
//               ),
//             if (widget.isOwner)
//               ListTile(
//                 leading: const Icon(Icons.delete, color: Colors.red),
//                 title: const Text(
//                   'Delete Post',
//                   style: TextStyle(color: Colors.red),
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _confirmDelete();
//                 },
//               ),
//           ],
//         );
//       },
//     );
//   }

//   void _showEditDialog() {
//     final controller = TextEditingController(text: widget.postText);
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Edit Post'),
//             content: TextField(
//               controller: controller,
//               maxLines: 3,
//               decoration: const InputDecoration(border: OutlineInputBorder()),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   widget.onUpdate(controller.text);
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Save'),
//               ),
//             ],
//           ),
//     );
//   }

//   void _confirmDelete() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Delete Post?'),
//             content: const Text('This action cannot be undone'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   widget.onDelete();
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 child: const Text('Delete'),
//               ),
//             ],
//           ),
//     );
//   }

//   void _showCommentModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(30),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 20,
//                     spreadRadius: 5,
//                   ),
//                 ],
//               ),
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 60,
//                       height: 5,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     const Text(
//                       'Comments',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     Expanded(
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: comments.length,
//                         itemBuilder: (context, index) {
//                           final comment = comments[index];
//                           final replies = comment['replies'] as List<dynamic>;
//                           final visibleReplies =
//                               replies.length <= 2
//                                   ? replies
//                                   : replies.sublist(replies.length - 2);

//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[50],
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 child: ListTile(
//                                   leading: Container(
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       border: Border.all(
//                                         color: Colors.pinkAccent.withOpacity(
//                                           0.5,
//                                         ),
//                                         width: 1.5,
//                                       ),
//                                     ),
//                                     child: CircleAvatar(
//                                       backgroundImage: NetworkImage(
//                                         widget.authorAvatarUrl.isNotEmpty
//                                             ? widget.authorAvatarUrl
//                                             : 'https://randomuser.me/api/portraits/men/1.jpg',
//                                       ),
//                                     ),
//                                   ),
//                                   title: Text(
//                                     comment['author'],
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   subtitle: Text(comment['text']),
//                                   trailing: IconButton(
//                                     icon: const Icon(
//                                       Icons.reply,
//                                       color: Colors.purpleAccent,
//                                     ),
//                                     onPressed:
//                                         () => _showReplyDialog(
//                                           index,
//                                           setModalState,
//                                         ),
//                                   ),
//                                 ),
//                               ),
//                               if (replies.length > 2)
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 40),
//                                   child: TextButton(
//                                     onPressed:
//                                         () => _showReplyDialog(
//                                           index,
//                                           setModalState,
//                                         ),
//                                     child: Text(
//                                       'View all ${replies.length} replies',
//                                       style: const TextStyle(
//                                         color: Colors.purpleAccent,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ...visibleReplies.map<Widget>((reply) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(
//                                     left: 40,
//                                     bottom: 6,
//                                   ),
//                                   child: ListTile(
//                                     contentPadding: EdgeInsets.zero,
//                                     leading: Container(
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         border: Border.all(
//                                           color: Colors.blueAccent.withOpacity(
//                                             0.5,
//                                           ),
//                                           width: 1.5,
//                                         ),
//                                       ),
//                                       child: CircleAvatar(
//                                         radius: 15,
//                                         backgroundImage: NetworkImage(
//                                           widget.authorAvatarUrl.isNotEmpty
//                                               ? widget.authorAvatarUrl
//                                               : 'https://randomuser.me/api/portraits/women/1.jpg',
//                                         ),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       reply['author'],
//                                       style: const TextStyle(fontSize: 14),
//                                     ),
//                                     subtitle: Text(
//                                       reply['text'],
//                                       style: const TextStyle(fontSize: 13),
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                               const SizedBox(height: 8),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                     const Divider(height: 20),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.grey[50],
//                               borderRadius: BorderRadius.circular(25),
//                               border: Border.all(
//                                 color: Colors.grey.withOpacity(0.2),
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                               ),
//                               child: TextField(
//                                 controller: commentController,
//                                 decoration: InputDecoration(
//                                   hintText: "Write a comment...",
//                                   hintStyle: TextStyle(color: Colors.grey[500]),
//                                   border: InputBorder.none,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF6E48AA), Color(0xFF9D50BB)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.purple.withOpacity(0.3),
//                                 spreadRadius: 1,
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: IconButton(
//                             icon: const Icon(Icons.send, color: Colors.white),
//                             onPressed: () {
//                               if (commentController.text.trim().isNotEmpty) {
//                                 setModalState(() {
//                                   comments.add({
//                                     'text': commentController.text.trim(),
//                                     'author': widget.authorName,
//                                     'replies': [],
//                                   });
//                                   commentController.clear();
//                                 });
//                                 setState(() {});
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showReplyDialog(int commentIndex, StateSetter setModalState) {
//     TextEditingController replyController = TextEditingController();
//     showDialog(
//       context: context,
//       builder:
//           (context) => Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 20,
//                     spreadRadius: 5,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     "Reply to comment",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     controller: replyController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       hintText: "Write your reply...",
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text(
//                           "Cancel",
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Container(
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFF6E48AA), Color(0xFF9D50BB)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.purple.withOpacity(0.3),
//                               spreadRadius: 1,
//                               blurRadius: 8,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: ElevatedButton(
//                           onPressed: () {
//                             final replyText = replyController.text.trim();
//                             if (replyText.isNotEmpty) {
//                               setModalState(() {
//                                 comments[commentIndex]['replies'].add({
//                                   'text': replyText,
//                                   'author': widget.authorName,
//                                 });
//                               });
//                               Navigator.pop(context);
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.transparent,
//                             shadowColor: Colors.transparent,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                           ),
//                           child: const Text(
//                             "Send",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final visibleComments =
//         comments.length <= 2 ? comments : comments.sublist(comments.length - 2);

//     return Container(
//       margin: const EdgeInsets.only(top: 16, right: 0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color.fromARGB(173, 197, 162, 67).withOpacity(0.2),
//             spreadRadius: 5,
//             blurRadius: 10,
//             offset: const Offset(10, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: Colors.pinkAccent.withOpacity(0.5),
//                       width: 1.5,
//                     ),
//                   ),
//                   child: CircleAvatar(
//                     backgroundImage: NetworkImage(
//                       widget.authorAvatarUrl.isNotEmpty
//                           ? widget.authorAvatarUrl
//                           : 'https://randomuser.me/api/portraits/men/1.jpg',
//                     ),
//                     radius: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.authorName,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       _timeAgo(widget.timestamp),
//                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//                 const Spacer(),
//                 if (widget.isOwner)
//                   IconButton(
//                     icon: const Icon(Icons.more_vert, color: Colors.grey),
//                     onPressed: () => _showPostOptions(context),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               widget.postText,
//               style: const TextStyle(fontSize: 15, height: 1.4),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 InkWell(
//                   onTap: () {
//                     widget.onLike();
//                   },
//                   borderRadius: BorderRadius.circular(20),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color:
//                           widget.isLiked
//                               ? Colors.red.withOpacity(0.1)
//                               : Colors.transparent,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       children: [
//                         const SizedBox(width: 8),
//                         Text(
//                           '${widget.likeCount}',
//                           style: TextStyle(
//                             color: widget.isLiked ? Colors.red : Colors.grey,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             const Divider(height: 1),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 InkWell(
//                   onTap: widget.onLike,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color:
//                           widget.isLiked
//                               ? Colors.blue.withOpacity(0.1)
//                               : Colors.transparent,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           widget.isLiked
//                               ? Icons.favorite
//                               : Icons.favorite_border,
//                           color: widget.isLiked ? Colors.red : Colors.grey,
//                           size: 24,
//                         ),
//                         const SizedBox(width: 5),
//                         Text(
//                           widget.isLiked ? 'Loved' : 'Love',
//                           style: TextStyle(
//                             color: widget.isLiked ? Colors.red : Colors.grey,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () => _showCommentModal(context),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Row(
//                       children: [
//                         Icon(Icons.comment_outlined, color: Colors.grey),
//                         SizedBox(width: 8),
//                         Text(
//                           'Comment',
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Row(
//                     children: [
//                       Icon(Icons.share_outlined, color: Colors.grey),
//                       SizedBox(width: 8),
//                       Text(
//                         'Share',
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (comments.isNotEmpty) const Divider(height: 20),
//             if (comments.length > 2)
//               Center(
//                 child: TextButton(
//                   onPressed: () => _showCommentModal(context),
//                   child: Text(
//                     'View all ${comments.length} comments',
//                     style: const TextStyle(
//                       color: Colors.purpleAccent,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ...visibleComments.map(
//               (comment) => Padding(
//                 padding: const EdgeInsets.only(top: 12.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: Colors.blueAccent.withOpacity(0.5),
//                           width: 1.5,
//                         ),
//                       ),
//                       child: CircleAvatar(
//                         radius: 15,
//                         backgroundImage: NetworkImage(
//                           widget.authorAvatarUrl.isNotEmpty
//                               ? widget.authorAvatarUrl
//                               : 'https://randomuser.me/api/portraits/men/1.jpg',
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[50],
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   comment['author'],
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   comment['text'],
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 8.0),
//                             child: TextButton(
//                               onPressed:
//                                   () => _showReplyDialog(
//                                     comments.indexOf(comment),
//                                     (s) => setState(() {}),
//                                   ),
//                               child: const Text(
//                                 "Reply",
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.purpleAccent,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _timeAgo(DateTime date) {
//     final now = DateTime.now();
//     final diff = now.difference(date);
//     if (diff.inSeconds < 60) return 'Just now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
//     if (diff.inHours < 24) return '${diff.inHours} hrs ago';
//     if (diff.inDays < 7) return '${diff.inDays} days ago';
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
