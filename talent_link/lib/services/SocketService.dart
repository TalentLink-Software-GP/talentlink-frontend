import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? chatSocket;
  IO.Socket? callSocket;
  IO.Socket? _presenceSocket;

  Future<void> initializePresence({
    required String url,
    required String userId,
    required String token,
  }) async {
    final completer = Completer<void>();

    _presenceSocket = IO.io('$url/presence', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionAttempts': double.maxFinite.toInt(),
      'extraHeaders': {'Authorization': 'Bearer $token'},
    });

    _presenceSocket!.onConnect((_) {
      _presenceSocket!.emit('register', userId);
      print('Presence socket connected');
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _presenceSocket!.on('registrationSuccess', (data) {
      print('Presence registration successful: $data');
    });

    _presenceSocket!.onDisconnect((_) => print('Presence socket disconnected'));

    _presenceSocket!.onError((err) {
      print('Presence socket error: $err');
      if (!completer.isCompleted) {
        completer.completeError(err);
      }
    });

    return completer.future;
  }

  Future<void> connect({
    required String url,
    required String userId,
    required Function(Map<String, dynamic>) onMessage,
    required Function(Map<String, dynamic>) onCallRequest,
    required Function onCallEnded,
    required Function(String reason) onCallFailed,
  }) async {
    final completer = Completer<void>();

    try {
      // Initialize chat socket
      chatSocket = IO.io('$url/chat', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionAttempts': 200000,
        'timeout': 20000,
      });

      // Initialize call socket
      callSocket = IO.io('$url/calls', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionAttempts': 200000,
        'timeout': 20000,
      });

      // Chat socket listeners
      chatSocket!.onConnect((_) {
        print("Chat socket connected");
        chatSocket!.emit('register', userId);
      });

      chatSocket!.on('registrationSuccess', (data) {
        print("Chat socket registration successful: $data");
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      chatSocket!.on("receiveMessage", (data) {
        onMessage(Map<String, dynamic>.from(data));
      });

      chatSocket!.onDisconnect((_) => print("Chat socket disconnected"));

      chatSocket!.onConnectError((err) {
        print("Chat connect error: $err");
        // Don't complete with error here as we still want to try the call socket
      });

      chatSocket!.onError((err) {
        print("Chat error: $err");
        // Don't complete with error here as we still want to try the call socket
      });

      // Call socket listeners
      callSocket!.onConnect((_) {
        print("Call socket connected");
        callSocket!.emit('register', userId);
      });

      callSocket!.on("callRequest", (data) {
        if (data != null) onCallRequest(Map<String, dynamic>.from(data));
      });

      callSocket!.on("callEnded", (_) => onCallEnded());

      callSocket!.on("callFailed", (data) {
        onCallFailed(data['reason'] ?? 'Unknown error');
      });

      callSocket!.onDisconnect((_) => print("Call socket disconnected"));

      callSocket!.onConnectError((err) => print("Call connect error: $err"));

      callSocket!.onError((err) => print("Call error: $err"));

      // Connect both sockets after setting up all listeners
      chatSocket!.connect();
      callSocket!.connect();

      // Set a timeout to avoid hanging forever
      Timer(Duration(seconds: 20), () {
        if (!completer.isCompleted) {
          completer.completeError('Socket connection timeout');
        }
      });

      return completer.future;
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
      return completer.future;
    }
  }

  IO.Socket getCallSocket() {
    if (callSocket == null) {
      throw StateError(
        'Call socket is not initialized. Call initializeCall() first.',
      );
    }
    return callSocket!;
  }

  void onCallEvent(String event, Function(dynamic) callback) {
    final callSocket = this.callSocket;
    if (callSocket != null) {
      callSocket.on(event, callback);
    }
  }

  void onChatEvent(String event, Function(dynamic) callback) {
    final chatSocket = this.chatSocket;
    if (chatSocket != null) {
      chatSocket.on(event, callback);
    }
  }

  void emitChat(String event, dynamic data) {
    chatSocket?.emit(event, data);
  }

  void emitCall(String event, dynamic data) {
    callSocket?.emit(event, data);
  }

  bool get isChatConnected => chatSocket?.connected ?? false;

  bool get isCallConnected => callSocket?.connected ?? false;

  void listenForStatusUpdates(Function(String, bool) onStatusChange) {
    chatSocket?.on('userStatusUpdate', (data) {
      final userId = data['userId'];
      final isOnline = data['isOnline'];
      print(
        "Status update for user $userId: ${isOnline ? 'Online' : 'Offline'}",
      );
      onStatusChange(userId, isOnline);
    });
  }

  void updatePresence(bool isOnline) {
    _presenceSocket?.emit('updatePresence', {
      'isOnline': isOnline,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void startHealthChecks() {
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (!isChatConnected) {
        chatSocket?.connect();
      }
    });
  }

  Future<void> registerFcmToken(String userId, String fcmToken) async {
    if (isChatConnected) {
      emitChat('registerFCMToken', {'userId': userId, 'fcmToken': fcmToken});
    }
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    required String senderName,
  }) async {
    if (!isChatConnected) {
      print('Chat socket not connected');
      return;
    }

    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'senderName': senderName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    emitChat('sendMessage', messageData);
  }

  void dispose() {
    chatSocket?.dispose();
    callSocket?.dispose();
    _presenceSocket?.disconnect();
    _presenceSocket?.dispose();
  }
}
