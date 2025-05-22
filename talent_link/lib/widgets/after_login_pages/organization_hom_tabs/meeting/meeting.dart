//new api all fixed i used api.env

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String baseUrl = dotenv.env['BASE_URL']!;

class ScheduleMeetingPage extends StatefulWidget {
  final String applicantId; // ID of the applicant to notify

  const ScheduleMeetingPage({Key? key, required this.applicantId})
    : super(key: key);

  @override
  _ScheduleMeetingPageState createState() => _ScheduleMeetingPageState();
}

class _ScheduleMeetingPageState extends State<ScheduleMeetingPage> {
  //192.168.1.7   static const String baseUrl = 'http://10.0.2.2:5000/api';

  // static const String baseUrl = 'http://192.168.1.7:5000/api';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String meetingId = const Uuid().v4();
  bool isLoading = false;
  Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? 'defaultUserId';
  }

  Future<void> pickDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    setState(() {
      selectedDate = pickedDate;
      selectedTime = pickedTime;
    });
  }

  Future<void> scheduleMeeting() async {
    if (selectedDate == null || selectedTime == null) return;

    final DateTime scheduledDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final String formattedDateTime = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(scheduledDateTime);

    final meetingLink = "https://meet.jit.si/$meetingId";

    setState(() => isLoading = true);

    // Backend API to save meeting to MongoDB and notify applicant
    final orgId = await getCurrentUserId();
    final response = await http.post(
      Uri.parse('$baseUrl/meetings/schedule'),
      headers: {'Content-Type': 'application/json'},

      body: jsonEncode({
        "meetingId": meetingId,
        "meetingLink": meetingLink,
        "scheduledDateTime": formattedDateTime,
        "applicantId": widget.applicantId,
        "title": "Interview",
        "organizationId": orgId,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meeting scheduled successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to schedule meeting.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule Interview")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => pickDateTime(context),
              child: const Text("Pick Date & Time"),
            ),
            const SizedBox(height: 16),
            if (selectedDate != null && selectedTime != null)
              Text(
                "Selected: ${DateFormat('yyyy-MM-dd').format(selectedDate!)} at ${selectedTime!.format(context)}",
              ),
            const SizedBox(height: 32),
            Center(
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text("Schedule Meeting"),
                        onPressed: scheduleMeeting,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
