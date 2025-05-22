// If you ever need moderator features (mute, kick, recording, etc.),
// you will need to implement a backend to generate JWT tokens for JaaS.
// For now, this app uses open meetings with equal permissions for all.

import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:intl/intl.dart';

class JoinMeetingPage extends StatelessWidget {
  final String meetingId;
  final String meetingLink;
  final String scheduledDateTime;

  const JoinMeetingPage({
    Key? key,
    required this.meetingId,
    required this.meetingLink,
    required this.scheduledDateTime,
  }) : super(key: key);

  bool isMeetingAvailable() {
    final DateTime scheduled = DateTime.parse(scheduledDateTime);
    final DateTime now = DateTime.now();
    return now.isAfter(scheduled) || now.isAtSameMomentAs(scheduled);
  }

  void joinMeeting() async {
    final options = JitsiMeetConferenceOptions(
      room: meetingId,
      serverURL: 'https://meet.ffmuc.net/', // or your custom server
      configOverrides: {
        'startWithAudioMuted': false,
        'startWithVideoMuted': false,
        'disableDeepLinking': true,
        'disableThirdPartyRequests': true,
        'disablePrejoinPage': true,
        'subject': 'Interview Meeting',
        'enableLobbyChat': false,
        'enableClosePage': true,
        'lobby.enabled': false,
      },
      featureFlags: {
        'lobby-mode.enabled': false,
        'prejoinpage.enabled': false,
        'add-people.enabled': false,
        'calendar.enabled': false,
        'chat.enabled': true,
        'close-captions.enabled': false,
        'conference-timer.enabled': true,
        'contact-support.enabled': false,
        'e2ee.enabled': false,
        'email.enabled': false,
        'feedback.enabled': false,
        'invite.enabled': false,
        'kick-out.enabled': false,
        'meeting-password.enabled': false,
        'moderator.enabled': false,
        'recording.enabled': false,
        'security-options.enabled': false,
        'tile-view.enabled': true,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: "AWWAD",
        email: 'user@example.com',
        avatar: 'https://example.com/avatar.jpg',
      ),
    );

    final sdk = JitsiMeet();
    await sdk.join(options);
  }

  @override
  Widget build(BuildContext context) {
    final available = isMeetingAvailable();
    return Scaffold(
      appBar: AppBar(title: const Text("Interview Meeting")),
      body: Center(
        child:
            available
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome, AWWAD",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.video_call),
                      label: const Text("Join Meeting"),
                      onPressed: joinMeeting,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_clock, size: 64, color: Colors.grey),
                    const SizedBox(height: 20),
                    Text(
                      "Meeting will start at $scheduledDateTime",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text("Please return at the scheduled time."),
                  ],
                ),
      ),
    );
  }
}
