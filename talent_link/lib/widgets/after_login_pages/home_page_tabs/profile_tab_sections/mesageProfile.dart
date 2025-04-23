import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';

class SearchUserPage extends StatefulWidget {
  final String currentUserId;

  SearchUserPage({required this.currentUserId});

  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  List<dynamic> chatHistory = [];
  final String baseUrl = 'http://10.0.2.2:5000/api';

  bool isSearching = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchChatHistory();
    startTimerForRealTimeUpdate();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimerForRealTimeUpdate() {
    timer = Timer.periodic(Duration(seconds: 30), (Timer t) {
      setState(() {});
    });
  }

  Future<void> fetchChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat-history/${widget.currentUserId}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> fetchedHistory = json.decode(response.body);

        fetchedHistory.sort((a, b) {
          DateTime timeA = DateTime.parse(a['lastMessageTimestamp']);
          DateTime timeB = DateTime.parse(b['lastMessageTimestamp']);
          return timeB.compareTo(timeA);
        });

        setState(() {
          chatHistory = fetchedHistory;
        });
      } else {
        print(
          'Failed to fetch chat history. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching chat history: $e');
    }
  }

  Future<void> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?q=$query'),
      );

      if (response.statusCode == 200) {
        setState(() {
          searchResults = json.decode(response.body);
        });
      } else {
        print(
          'Failed to fetch search results. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error searching users: $e');
    }
  }

  Future<void> deleteChatHistory(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chat-history/${widget.currentUserId}/$userId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          chatHistory =
              chatHistory.where((user) => user['_id'] != userId).toList();
        });
      } else {
        print(
          'Failed to delete chat history. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error deleting chat history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search & Chat"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.blueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search users...",
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (query) {
                    if (query.isNotEmpty) {
                      setState(() {
                        isSearching = true;
                      });
                      searchUsers(query);
                    } else {
                      setState(() {
                        isSearching = false;
                      });
                      searchResults = [];
                    }
                  },
                ),
              ),
              if (!isSearching) Expanded(child: buildChatHistory()),
            ],
          ),
          if (isSearching) buildSearchResultsWindow(),
        ],
      ),
    );
  }

  Widget buildChatHistory() {
    return ListView.builder(
      itemCount: chatHistory.length,
      itemBuilder: (context, index) {
        final user = chatHistory[index];
        final lastChatTime = DateTime.parse(user['lastMessageTimestamp']);
        final timeDifference = DateTime.now().difference(lastChatTime);

        String timeDisplay;
        if (timeDifference.inMinutes < 1) {
          timeDisplay = 'Just now';
        } else if (timeDifference.inMinutes < 60) {
          timeDisplay = '${timeDifference.inMinutes} minutes ago';
        } else if (timeDifference.inHours < 24) {
          timeDisplay = '${timeDifference.inHours} hours ago';
        } else {
          timeDisplay = '${timeDifference.inDays} days ago';
        }

        return Dismissible(
          key: Key(user['_id']),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            deleteChatHistory(user['_id']);
          },
          background: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    user['avatarUrl'] != null && user['avatarUrl'].isNotEmpty
                        ? NetworkImage(user['avatarUrl'])
                        : AssetImage('assets/placeholder.png') as ImageProvider,
              ),
              title: Text(
                user['username'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Last chatted: $timeDisplay',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChatPage(
                          currentUserId: widget.currentUserId,
                          peerUserId: user['_id'],
                          peerUsername: user['username'],
                          onChatClosed: () {
                            fetchChatHistory();
                          },
                        ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildSearchResultsWindow() {
    return Positioned(
      top: 90,
      left: 20,
      right: 20,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final user = searchResults[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    user['profilePhoto'] != null &&
                            user['profilePhoto'].isNotEmpty
                        ? NetworkImage(user['profilePhoto'])
                        : AssetImage('assets/placeholder.png') as ImageProvider,
              ),
              title: Text(
                user['username'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user['email']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ChatPage(
                          currentUserId: widget.currentUserId,
                          peerUserId: user['_id'],
                          peerUsername: user['username'],
                          onChatClosed: () {
                            fetchChatHistory(); // Refresh chat history on return
                          },
                        ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// chatPage
class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String peerUserId;
  final String peerUsername;
  final VoidCallback onChatClosed;

  ChatPage({
    required this.currentUserId,
    required this.peerUserId,
    required this.peerUsername,
    required this.onChatClosed,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  String peerUsername = '';
  String peerAvatar = '';

  final String baseUrl = 'http://10.0.2.2:5000/api';

  @override
  void initState() {
    super.initState();
    fetchPeerInfo();
    fetchMessages();
  }

  Future<void> fetchPeerInfo() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/users/getUserData?userName=${widget.peerUsername}'),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          peerUsername = data['name'] ?? 'Unknown';
          peerAvatar = data['avatarUrl'] ?? '';
        });
      } else {
        print('Failed to fetch peer info. Status code: ${res.statusCode}');
      }
    } catch (e) {
      print('Error fetching peer info: $e');
    }
  }

  Future<void> fetchMessages() async {
    final res = await http.get(
      Uri.parse(
        '$baseUrl/messages/${widget.currentUserId}/${widget.peerUserId}',
      ),
    );

    if (res.statusCode == 200) {
      setState(() {
        messages = List<Map<String, dynamic>>.from(json.decode(res.body));
      });
    } else {
      print("Failed to load messages");
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final res = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'senderId': widget.currentUserId,
        'receiverId': widget.peerUserId,
        'message': text,
      }),
    );

    if (res.statusCode == 201) {
      messageController.clear();
      fetchMessages();
    }
  }

  void _showUserOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blueAccent),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Go to user profile')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_off, color: Colors.blueAccent),
              title: const Text('Mute'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Muted user')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.redAccent),
              title: const Text('Block'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('User blocked')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orangeAccent),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Reported user')));
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 2,
        title: GestureDetector(
          onTap: () => _showUserOptions(context),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    peerAvatar.isNotEmpty
                        ? NetworkImage(peerAvatar)
                        : AssetImage('assets/placeholder.png') as ImageProvider,
              ),
              SizedBox(width: 10),
              Text(
                peerUsername.isNotEmpty ? peerUsername : 'Loading...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            widget.onChatClosed();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  var msg = messages[messages.length - 1 - index];
                  var isMe = msg['senderId'] == widget.currentUserId;
                  var time =
                      msg['timestamp'] != null
                          ? DateFormat(
                            'hh:mm a',
                          ).format(DateTime.parse(msg['timestamp']))
                          : "";

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient:
                            isMe
                                ? LinearGradient(
                                  colors: [Colors.blueAccent, Colors.lightBlue],
                                )
                                : LinearGradient(
                                  colors: [Colors.grey, Colors.grey.shade400],
                                ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['message'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  isMe ? Colors.white70 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Colors.white),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
