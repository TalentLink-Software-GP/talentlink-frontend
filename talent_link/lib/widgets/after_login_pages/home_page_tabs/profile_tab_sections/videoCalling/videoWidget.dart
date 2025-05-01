import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VideoWidget extends StatefulWidget {
  final String currentUserId;
  final String peerUserId;
  final String peerUsername;
  final IO.Socket socket;
  final bool isInitiator;
  final String conferenceID;

  const VideoWidget({
    Key? key,
    required this.currentUserId,
    required this.peerUserId,
    required this.peerUsername,
    required this.socket,
    this.isInitiator = true,
    required this.conferenceID,
  }) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  bool isCallAccepted = false;
  bool isCallRejected = false;
  bool isCallEnded = false;
  Timer? callTimer;
  String callStatus = 'Calling...';

  // Generate a unique conference ID for the call
  String get conferenceID => widget.conferenceID;

  @override
  void initState() {
    super.initState();

    print(
      "VideoWidget initialized with: currentUserId=${widget.currentUserId}, peerUserId=${widget.peerUserId}",
    );

    // Register the user's socket connection
    widget.socket.emit('register', widget.currentUserId);

    if (widget.isInitiator) {
      _sendCallRequest();
      callStatus = 'Calling...';
    } else {
      _sendCallAccepted();
      setState(() {
        isCallAccepted = true;
        callStatus = 'Connected';
      });
    }

    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    // Listen for call accepted event
    widget.socket.on('callAccepted', (data) {
      print("Call accepted event received: $data");

      // Check if this event is for our call
      if (data != null &&
          ((data['callerId'] == widget.currentUserId &&
                  data['receiverId'] == widget.peerUserId) ||
              (data['callerId'] == widget.peerUserId &&
                  data['receiverId'] == widget.currentUserId))) {
        print("Call accepted by peer, joining conference");

        setState(() {
          isCallAccepted = true;
          callStatus = 'Connected';
        });
      }
    });

    // Listen for call rejected event
    widget.socket.on('callRejected', (data) {
      if (data['callerId'] == widget.currentUserId &&
          data['receiverId'] == widget.peerUserId) {
        setState(() {
          isCallRejected = true;
          callStatus = 'Call Rejected';
        });
        // Navigate back after a short delay
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    });

    // Listen for call ended event
    widget.socket.on('callEnded', (data) {
      if ((data['callerId'] == widget.currentUserId &&
              data['receiverId'] == widget.peerUserId) ||
          (data['callerId'] == widget.peerUserId &&
              data['receiverId'] == widget.currentUserId)) {
        setState(() {
          isCallEnded = true;
          callStatus = 'Call Ended';
        });
        // Navigate back after a short delay
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    });
  }

  void _sendCallRequest() {
    final callData = {
      'callerId': widget.currentUserId,
      'receiverId': widget.peerUserId,
      'callerName': 'User_${widget.currentUserId}', // Make sure this is set
      'conferenceId': widget.conferenceID, // Use the passed conferenceID
      'timestamp': DateTime.now().toIso8601String(),
    };

    print("Sending call request with data: $callData"); // Add logging
    widget.socket.emit('callRequest', callData);
  }

  void _sendCallAccepted() {
    final callData = {
      'callerId': widget.peerUserId,
      'receiverId': widget.currentUserId,
      'conferenceId': widget.conferenceID,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print("Sending call accepted: $callData");
    widget.socket.emit('callAccepted', callData);
  }

  void _sendCallRejected() {
    final callData = {
      'callerId': widget.peerUserId,
      'receiverId': widget.currentUserId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    widget.socket.emit('callRejected', callData);
  }

  void _sendCallEnded() {
    final callData = {
      'callerId': widget.currentUserId,
      'receiverId': widget.peerUserId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    widget.socket.emit('callEnded', callData);
  }

  void _startCallTimeoutTimer() {
    callTimer = Timer(Duration(seconds: 30), () {
      if (!isCallAccepted && !isCallRejected && !isCallEnded) {
        setState(() {
          callStatus = 'No Answer';
        });
        _sendCallEnded();
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  void dispose() {
    callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _sendCallEnded();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            if (isCallAccepted)
              ZegoUIKitPrebuiltVideoConference(
                appID: 871480527,
                appSign:
                    'eb6aebf3c532a731f17deb12859b8a25790b9d8fdff4ffc5e9bc009e1fa42435',
                userID: widget.currentUserId,
                userName: 'User_${widget.currentUserId}',
                conferenceID: widget.conferenceID,
                config: ZegoUIKitPrebuiltVideoConferenceConfig(
                  onLeaveConfirmation: (context) async {
                    _sendCallEnded();
                    return true;
                  },
                  audioVideoViewConfig: ZegoPrebuiltAudioVideoViewConfig(
                    foregroundBuilder: (
                      BuildContext context,
                      Size size,
                      ZegoUIKitUser? user,
                      Map extraInfo,
                    ) {
                      return Positioned(
                        bottom: 5,
                        left: 5,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user?.name ?? '',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            if (!isCallAccepted && !isCallRejected && !isCallEnded)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      widget.peerUsername,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      callStatus,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 40),
                    if (widget.isInitiator)
                      GestureDetector(
                        onTap: () {
                          _sendCallEnded();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            if (isCallRejected || isCallEnded)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      callStatus,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
