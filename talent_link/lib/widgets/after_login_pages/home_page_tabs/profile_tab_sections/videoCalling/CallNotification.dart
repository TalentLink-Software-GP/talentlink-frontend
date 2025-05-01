import 'package:flutter/material.dart';

class CallNotification extends StatelessWidget {
  final Map<String, dynamic> callData;
  final Function onDismiss;
  final Function onReject;
  final Function onAccept;

  const CallNotification({
    Key? key,
    required this.callData,
    required this.onDismiss,
    required this.onReject,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final callerName = callData['callerName'] ?? 'Unknown Caller';

    return Card(
      color: Colors.indigo.shade800,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.person, size: 40, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        callerName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Incoming video call',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.call_end),
                  label: Text("Decline"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    try {
                      onReject();
                      onDismiss();
                    } catch (e) {
                      print("Error in decline button: $e");
                    }
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.videocam),
                  label: Text("Accept"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    try {
                      onAccept();
                      onDismiss();
                    } catch (e) {
                      print("Error in accept button: $e");
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
