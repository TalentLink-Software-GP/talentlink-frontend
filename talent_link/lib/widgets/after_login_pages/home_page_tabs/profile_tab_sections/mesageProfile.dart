import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/messageNotifications.dart';

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
  final String baseUrl = 'http://10.0.2.2:5000/api'; //or 192.168.1.54

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
      final response = await http.put(
        Uri.parse('$baseUrl/delete-message/${widget.currentUserId}/$userId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          chatHistory =
              chatHistory.where((user) => user['_id'] != userId).toList();
        });
      } else {
        print('Failed to hide chat. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error hiding chat: $e');
    }
  }

  Future<int> fetchUnreadMessageCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/unread-count/${widget.currentUserId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unreadCount'] ?? 0;
      } else {
        print(
          'Failed to fetch unread message count. Status code: ${response.statusCode}',
        );
        return 0;
      }
    } catch (e) {
      print('Error fetching unread message count: $e');
      return 0;
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
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        user['avatarUrl'] != null &&
                                user['avatarUrl'].isNotEmpty
                            ? NetworkImage(user['avatarUrl'])
                            : AssetImage('assets/placeholder.png')
                                as ImageProvider,
                  ),
                  if ((user['unreadCount'] ?? 0) > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${user['unreadCount']}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
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
              trailing: MessageNotification(count: 5),
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
                            fetchChatHistory();
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

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool show = true;
  String peerUsername = '';
  String peerAvatar = '';
  final String baseUrl = 'http://10.0.2.2:5000/api';
  late IO.Socket socket;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!socket.connected) {
        socket.connect();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchPeerInfo();
    fetchMessages();
    connect();
  }

  Future<void> connect() async {
    final ip =
        (await NetworkInterface.list())
            .expand((i) => i.addresses)
            .firstWhere(
              (a) => a.type == InternetAddressType.IPv4 && !a.isLoopback,
            )
            .address;
    socket = IO.io("http://$ip:5000", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionAttempts': 200000,
      'timeout': 20000,
    });

    socket.connect();

    socket.onConnect((_) {
      print("Socket connected");
    });

    socket.onDisconnect((_) {
      print("Socket disconnected");
    });
    socket.onConnectError((err) => print("Connect error: $err"));
    socket.onError((err) => print("Error: $err"));

    socket.onReconnect((attempt) {
      print("Reconnected after $attempt attempts");
    });

    socket.onError((err) {
      print("Socket error: $err");
    });

    socket.on("receiveMessage", (data) {
      final alreadyExists = messages.any(
        (msg) =>
            msg['senderId'] == data['senderId'] &&
            msg['receiverId'] == data['receiverId'] &&
            msg['message'] == data['message'],
      );

      if (!alreadyExists) {
        setState(() {
          messages.add({
            "senderId": data["senderId"],
            "receiverId": data["receiverId"],
            "message": data["message"],
            "timestamp": DateTime.now().toIso8601String(),
          });
        });
      }
    });
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

  bool isSending = false;

  Future<void> sendMessage() async {
    if (isSending) return;
    isSending = true;

    final text = messageController.text.trim();
    if (text.length < 1) {
      isSending = false;
      return;
    }

    final messageData = {
      'senderId': widget.currentUserId,
      'receiverId': widget.peerUserId,
      'message': text,
    };

    try {
      if (socket.disconnected) {
        socket.connect();
        await Future.delayed(Duration(milliseconds: 500));
      }

      socket.emit("sendMessage", messageData);

      messageController.clear();

      await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(messageData),
      );
    } catch (e) {
      print("Error sending message: $e");
    } finally {
      isSending = false;
    }
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
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

  // Future<int> fetchUnreadCount(String userId) async {
  //   final response = await http.get(
  //     Uri.parse('http://10.0.2.2:5000//api/messages/unread-count/$userId'),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return data['unreadCount'] ?? 0;
  //   } else {
  //     throw Exception('Failed to load unread count');
  //   }
  // }

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
