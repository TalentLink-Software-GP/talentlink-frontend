import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:talent_link/services/socket_service.dart';
import 'package:talent_link/services/message_service.dart';
import 'package:talent_link/services/search_page_services.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/message_notifications.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/post_sections/profile_widget_for_another_users.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/videoCalling/call_notification.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/videoCalling/video_widget.dart';

class SearchUserPage extends StatefulWidget {
  final String currentUserId;
  final String avatarUrl;
  final String token;

  const SearchUserPage({
    super.key,
    required this.currentUserId,
    required this.avatarUrl,
    required this.token,
  });

  @override
  SearchUserPageState createState() => SearchUserPageState();
}

class SearchUserPageState extends State<SearchUserPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  List<dynamic> chatHistory = [];
  final String baseUrl =
      'http://10.0.2.2:5000/api'; //https://talentlink-backend-c01n.onrender.com
  String? uploadedImageUrl;
  final SearchPageService _service = SearchPageService();

  bool isSearching = false;
  Timer? timer;
  int finalcount = 0;

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
    final history = await _service.fetchChatHistory(widget.currentUserId);

    // Get unread counts for each conversation
    final updatedHistory = await Future.wait(
      history.map((user) async {
        finalcount = await _service.getUnreadCount(
          widget.currentUserId,
          user['_id'],
        );
        return {...user, 'unreadCount': finalcount};
      }),
    );

    setState(() {
      chatHistory = updatedHistory;
    });
  }

  Future<void> searchUsers(String query) async {
    final results = await _service.searchUsers(query);
    setState(() {
      searchResults = results;
    });
  }

  Future<void> deleteChatHistory(String userId) async {
    bool success = await _service.deleteChatHistory(
      widget.currentUserId,
      userId,
    );
    if (success) {
      setState(() {
        chatHistory =
            chatHistory.where((user) => user['_id'] != userId).toList();
      });
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
                    fillColor: Colors.white.withAlpha(204),
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
                            : AssetImage('assets/images/avatarPlaceholder.jpg')
                                as ImageProvider,
                  ),

                  //TODO: when user1 send a message to user2 i need the Count of notification (finalcount or unReadCount) to be in realTime that dont need to refresh the page to show the notifications
                  if ((user['unreadCount'] ?? 0) > 0) // here's
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
                          currentuserAvatarUrl: widget.avatarUrl,
                          token: widget.token,
                          onChatClosed: () {
                            fetchChatHistory();

                            // currentuserAvatarUrl:widget.avatarUrl;
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
          color: Colors.white.withAlpha(51),
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
                    user['avatarUrl'] != null && user['avatarUrl'].isNotEmpty
                        ? NetworkImage(user['avatarUrl'])
                        : AssetImage('assets/images/avatarPlaceholder.jpg')
                            as ImageProvider,
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
                          token: widget.token,

                          currentuserAvatarUrl: widget.avatarUrl,
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
  final String currentuserAvatarUrl;
  final String token;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.peerUserId,
    required this.peerUsername,
    required this.onChatClosed,
    required this.currentuserAvatarUrl,
    required this.token,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final _logger = Logger();
  bool showCallNotification = false;
  Map<String, dynamic>? incomingCallData;
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool show = true;
  bool isOnline = false;
  DateTime? lastSeen;

  late final SocketService socketService;
  late final MessageService2 messageService;
  String peerUsername = '';
  String peerAvatar = '';
  final String baseUrl =
      'http://10.0.2.2:5000/api'; //https://talentlink-backend-c01n.onrender.com

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground - mark as online
        socketService.updatePresence(true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // App is in background - mark as offline
        socketService.updatePresence(false);
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    socketService = SocketService();
    messageService = MessageService2();
    socketService.startHealthChecks();

    fetchPeerInfo();
    fetchMessages();
    initSocket();

    // Initialize status tracking
    _initializePresence();
    _markMessagesAsRead(); // Add this line
  }

  void _initializePresence() {
    // Listen for status updates
    socketService.listenForStatusUpdates((userId, onlineStatus) {
      if (userId == widget.peerUserId) {
        setState(() {
          isOnline = onlineStatus;
          if (!onlineStatus) {
            lastSeen = DateTime.now();
          }
        });
      }
    });

    // Fetch initial status
    _fetchInitialStatus();
  }

  Future<void> initSocket() async {
    final socketUrl = baseUrl.replaceAll('/api', '');
    if (socketService.isChatConnected) {
      socketService.chatSocket?.disconnect();
    }
    await socketService.connect(
      url: socketUrl,
      userId: widget.currentUserId,
      onMessage: (data) {
        final isDuplicate = messages.any(
          (msg) =>
              msg['message'] == data['message'] &&
              msg['senderId'] == data['senderId'] &&
              (msg['timestamp'] == data['timestamp'] ||
                  DateTime.parse(msg['timestamp'])
                          .difference(DateTime.parse(data['timestamp']))
                          .inSeconds
                          .abs() <
                      5),
        );

        if (!isDuplicate) {
          _handleIncomingMessage(data);
        }
      },

      onCallRequest: (data) {
        if (data['receiverId'] == widget.currentUserId) {
          setState(() {
            showCallNotification = true;
            incomingCallData = {
              'callerId': data['callerId'],
              'receiverId': data['receiverId'],
              'callerName': data['callerName'] ?? 'Unknown Caller',
              'conferenceId': data['conferenceId'] ?? 'default_conference',
              'timestamp':
                  data['timestamp'] ?? DateTime.now().toIso8601String(),
            };
          });
        }
      },
      onCallEnded: () {
        setState(() {
          showCallNotification = false;
          incomingCallData = null;
        });
      },
      onCallFailed: (reason) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Call failed: $reason"),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Future<void> _fetchInitialStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/${widget.peerUserId}/status'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isOnline = data['online'] ?? false;
          lastSeen =
              data['lastSeen'] != null
                  ? DateTime.parse(data['lastSeen'])
                  : null;
        });
      }
    } catch (e) {
      _logger.e('Error fetching initial status', error: e);
    }
  }

  Future<void> fetchPeerInfo() async {
    final data = await messageService.fetchPeerInfo(widget.peerUsername);
    if (data != null) {
      setState(() {
        peerUsername = data['name'] ?? 'Unknown';
        peerAvatar = data['avatarUrl'] ?? '';
      });
    } else {
      _logger.w('Failed to fetch peer info');
    }
  }

  void _handleIncomingMessage(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        messages.add({
          "senderId": data["senderId"],
          "receiverId": data["receiverId"],
          "message": data["message"],
          "timestamp": DateTime.now().toIso8601String(),
        });
      });
    });
  }

  Future<void> fetchMessages() async {
    final msgs = await messageService.fetchMessages(
      widget.currentUserId,
      widget.peerUserId,
    );
    setState(() {
      messages = msgs;
    });
  }

  bool isSending = false;

  Future<void> sendMessage() async {
    if (isSending || !socketService.isChatConnected) return;

    if (isSending) return;
    isSending = true;

    final text = messageController.text.trim();
    if (text.isEmpty) {
      isSending = false;
      return;
    }

    try {
      if (!socketService.isChatConnected ||
          socketService.chatSocket?.disconnected == true) {
        await initSocket();
        await Future.delayed(Duration(seconds: 1)); // Give time to reconnect
      }

      final messageData = {
        'senderId': widget.currentUserId,
        'receiverId': widget.peerUserId,
        'message': text,
        'timestamp': DateTime.now().toIso8601String(), // Add timestamp
      };

      socketService.emitChat("sendMessage", messageData);
      messageController.clear();

      // Optimistically add to UI
      _handleIncomingMessage(messageData);

      await messageService.sendMessage(messageData);
    } catch (e) {
      // Error handling
    } finally {
      isSending = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    socketService.dispose();
    super.dispose();
  }

  void _initiateVideoCall() async {
    if (!socketService.isCallConnected) {
      _logger.w("⚠️ Call socket not connected, attempting to reconnect...");
      socketService.callSocket?.connect();
      await Future.delayed(Duration(seconds: 1));

      if (!socketService.isCallConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to connect to call service")),
        );
        return;
      }
    }

    final conferenceID =
        "${widget.currentUserId}_${widget.peerUserId}_${DateTime.now().millisecondsSinceEpoch}";

    final callData = {
      'callerId': widget.currentUserId,
      'receiverId': widget.peerUserId,
      'callerName': peerUsername,
      'conferenceId': conferenceID,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logger.i("Initiating video call with data: $callData");

    socketService.emitCall('callRequest', callData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VideoWidget(
              currentUserId: widget.currentUserId,
              peerUserId: widget.peerUserId,
              peerUsername: peerUsername,
              socket: socketService.callSocket!, // ✅ Call namespace socket
              isInitiator: true,
              conferenceID: conferenceID,
            ),
      ),
    );
  }

  void _acceptCall() {
    _logger.d("Accepting call with data: $incomingCallData");

    try {
      if (incomingCallData == null) {
        _logger.e("No incoming call data available");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No active call to accept"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final callerId = incomingCallData?['callerId'];
      final callerName = incomingCallData?['callerName'] ?? 'Unknown Caller';
      final conferenceId =
          incomingCallData?['conferenceId'] ?? 'default_conference';

      if (callerId == null) {
        throw Exception("Caller ID is missing from call data");
      }

      setState(() {
        showCallNotification = false;
        incomingCallData = null;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => VideoWidget(
                currentUserId: widget.currentUserId,
                peerUserId: callerId,
                peerUsername: callerName,
                socket: socketService.callSocket!, // ✅ Call namespace socket
                isInitiator: false,
                conferenceID: conferenceId,
              ),
        ),
      );
    } catch (e, stackTrace) {
      _logger.e("Error in _acceptCall", error: e, stackTrace: stackTrace);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error accepting call: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        showCallNotification = false;
        incomingCallData = null;
      });
    }
  }

  void _rejectCall() {
    if (incomingCallData != null) {
      final callData = {
        'callerId': incomingCallData!['callerId'],
        'receiverId': widget.currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      socketService.emitCall('callRejected', callData);
      _logger.i("Call rejected with data: $callData");
    }
  }

  void _markMessagesAsRead() async {
    bool success = await messageService.markMessagesAsRead(
      widget.currentUserId,
      widget.peerUserId,
    );

    if (success) {
      // Update local state to reflect read status
      setState(() {
        messages =
            messages.map((msg) {
              if (msg['receiverId'] == widget.currentUserId) {
                return {...msg, 'isRead': true};
              }
              return msg;
            }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProfileWidgetForAnotherUsers(
                      username: widget.peerUsername,
                      token: widget.token,
                    ),
              ),
            );
          },
          child: Row(
            children: [
              Hero(
                tag: 'avatar-$peerUsername',
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        peerAvatar.isNotEmpty
                            ? NetworkImage(peerAvatar)
                            : AssetImage('assets/images/avatarPlaceholder.jpg')
                                as ImageProvider,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    peerUsername.isNotEmpty ? peerUsername : 'Loading...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    isOnline
                        ? 'Online'
                        : lastSeen != null
                        ? 'Last seen ${DateFormat.jm().format(lastSeen!)}'
                        : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnline ? Colors.greenAccent : Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () {
            widget.onChatClosed();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam, color: Colors.white),
            onPressed: _initiateVideoCall,
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showChatOptions(context),
          ),
        ],
      ),
      body: Stack(
        // Changed from Container to Stack
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A237E),
                  Color(0xFF3949AB),
                  Color(0xFF5C6BC0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Date indicator
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 12),
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
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment:
                              isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe)
                              CircleAvatar(
                                radius: 12,
                                backgroundImage:
                                    peerAvatar.isNotEmpty
                                        ? NetworkImage(peerAvatar)
                                        : AssetImage(
                                              'assets/images/avatarPlaceholder.jpg',
                                            )
                                            as ImageProvider,
                              ),
                            if (!isMe) SizedBox(width: 8),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isMe
                                        ? Colors.indigoAccent.shade400
                                        : Colors.white.withAlpha(230),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomLeft:
                                      isMe
                                          ? Radius.circular(18)
                                          : Radius.circular(0),
                                  bottomRight:
                                      isMe
                                          ? Radius.circular(0)
                                          : Radius.circular(18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg['message'],
                                    style: TextStyle(
                                      color:
                                          isMe ? Colors.white : Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        time,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              isMe
                                                  ? Colors.white70
                                                  : Colors.black54,
                                        ),
                                      ),
                                      if (isMe)
                                        // TODO: when user1 send message to user2 and user2 is in chat i need to show for user 1 that user2 seen the message, i do that but i need it in realTime
                                        Padding(
                                          padding: EdgeInsets.only(left: 4),
                                          child: Icon(
                                            msg['isRead'] == true
                                                ? Icons.done_all
                                                : Icons.done,
                                            size: 14,
                                            color:
                                                msg['isRead'] == true
                                                    ? Colors.blue[200]
                                                    : Colors.white70,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isMe) SizedBox(width: 8),
                            if (isMe)
                              CircleAvatar(
                                radius: 12,
                                backgroundImage:
                                    widget.currentuserAvatarUrl.isNotEmpty
                                        ? NetworkImage(
                                          widget.currentuserAvatarUrl,
                                        )
                                        : AssetImage(
                                              'assets/images/avatarPlaceholder.jpg',
                                            )
                                            as ImageProvider,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.attach_file_rounded,
                          color: Colors.white70,
                        ),
                        onPressed: () => _showAttachmentOptions(context),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: TextField(
                            controller: messageController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.indigoAccent, Colors.purpleAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withAlpha(77),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send_rounded, color: Colors.white),
                          onPressed: sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Now the call notification is properly placed in the Stack
          if (showCallNotification && incomingCallData != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: CallNotification(
                  callerName:
                      incomingCallData!['callerName'] ?? 'Unknown Caller',
                  onDismiss: () {
                    setState(() {
                      showCallNotification = false;
                      incomingCallData = null;
                    });
                  },
                  onReject: _rejectCall,
                  onAccept: _acceptCall,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Add these helper methods to your class
  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.search, color: Colors.white),
                  title: Text(
                    'Search in conversation',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.white),
                  title: Text(
                    'Mute notifications',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: Text(
                    'Clear chat',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _attachmentOption(
                      context,
                      Icons.photo,
                      'Gallery',
                      Colors.green,
                    ),
                    _attachmentOption(
                      context,
                      Icons.camera_alt,
                      'Camera',
                      Colors.blue,
                    ),
                    _attachmentOption(
                      context,
                      Icons.insert_drive_file,
                      'Document',
                      Colors.orange,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _attachmentOption(
                      context,
                      Icons.location_on,
                      'Location',
                      Colors.red,
                    ),
                    _attachmentOption(
                      context,
                      Icons.person,
                      'Contact',
                      Colors.purple,
                    ),
                    _attachmentOption(
                      context,
                      Icons.music_note,
                      'Audio',
                      Colors.teal,
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  //awad
  Widget _attachmentOption(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}
