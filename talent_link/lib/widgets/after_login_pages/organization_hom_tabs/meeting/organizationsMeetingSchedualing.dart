//new api all fixed i used api.env

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:talent_link/widgets/after_login_pages/organization_hom_tabs/meeting/joinMeeting.dart';

final String baseUrl = dotenv.env['BASE_URL']!;

class OrganizationMeetingsPage extends StatefulWidget {
  final String organizationId;

  const OrganizationMeetingsPage({super.key, required this.organizationId});

  @override
  State<OrganizationMeetingsPage> createState() =>
      _OrganizationMeetingsPageState();
}

class _OrganizationMeetingsPageState extends State<OrganizationMeetingsPage> {
  //192.168.1.7    static const String baseUrl = 'http://10.0.2.2:5000/api';

  // static const String baseUrl = 'http://192.168.1.7:5000/api';

  List<dynamic> meetings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMeetings();
  }

  Future<void> fetchMeetings() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/meetings/organizationFetchMeeting/${widget.organizationId}',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        meetings = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      print('Failed to load meetings');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upcoming Meetings")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : meetings.isEmpty
              ? const Center(child: Text("No upcoming meetings"))
              : ListView.builder(
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  return ListTile(
                    title: Text(meeting['title']),
                    subtitle: Text(meeting['scheduledDateTime']),
                    trailing: const Icon(Icons.video_call),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => JoinMeetingPage(
                                meetingId: meeting['meetingId'],
                                meetingLink: meeting['meetingLink'],
                                scheduledDateTime: meeting['scheduledDateTime'],
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
