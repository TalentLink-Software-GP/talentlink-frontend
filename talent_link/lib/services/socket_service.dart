import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logger/logger.dart';

class SocketService {
  io.Socket? chatSocket;
  io.Socket? callSocket;
  io.Socket? _presenceSocket;
  final _logger = Logger();

  Future<void> initializePresence({
    required String url,
    required String userId,
    required String token,
  }) async {
    final completer = Completer<void>();

    _presenceSocket = io.io('$url/presence', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionDelay': 1000,
      'reconnectionAttempts': double.maxFinite.toInt(),
      'extraHeaders': {'Authorization': 'Bearer $token'},
    });

    _presenceSocket!.onConnect((_) {
      _presenceSocket!.emit('register', userId);
      _logger.i('Presence socket connected');
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _presenceSocket!.on('registrationSuccess', (data) {
      _logger.i('Presence registration successful: $data');
    });

    _presenceSocket!.onDisconnect(
      (_) => _logger.w('Presence socket disconnected'),
    );

    _presenceSocket!.onError((err) {
      _logger.e('Presence socket error:', error: err);
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
      chatSocket = io.io('$url/chat', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionAttempts': 200000,
        'timeout': 20000,
      });

      // Initialize call socket
      callSocket = io.io('$url/calls', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionDelay': 1000,
        'reconnectionAttempts': 200000,
        'timeout': 20000,
      });

      // Chat socket listeners
      chatSocket!.onConnect((_) {
        _logger.i("Chat socket connected");
        chatSocket!.emit('register', userId);
      });

      chatSocket!.on('registrationSuccess', (data) {
        _logger.i("Chat socket registration successful: $data");
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      chatSocket!.on("receiveMessage", (data) {
        onMessage(Map<String, dynamic>.from(data));
      });

      chatSocket!.onDisconnect((_) => _logger.w("Chat socket disconnected"));

      chatSocket!.onConnectError((err) {
        _logger.e("Chat connect error:", error: err);
      });

      chatSocket!.onError((err) {
        _logger.e("Chat error:", error: err);
      });

      // Call socket listeners
      callSocket!.onConnect((_) {
        _logger.i("Call socket connected");
        callSocket!.emit('register', userId);
      });

      callSocket!.on("callRequest", (data) {
        if (data != null) onCallRequest(Map<String, dynamic>.from(data));
      });

      callSocket!.on("callEnded", (_) => onCallEnded());

      callSocket!.on("callFailed", (data) {
        onCallFailed(data['reason'] ?? 'Unknown error');
      });

      callSocket!.onDisconnect((_) => _logger.w("Call socket disconnected"));

      callSocket!.onConnectError(
        (err) => _logger.e("Call connect error:", error: err),
      );

      callSocket!.onError((err) => _logger.e("Call error:", error: err));

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

  io.Socket getCallSocket() {
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
      _logger.i(
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
      _logger.w('Chat socket not connected');
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
