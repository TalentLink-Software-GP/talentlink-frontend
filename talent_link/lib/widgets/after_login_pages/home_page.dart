import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:talent_link/services/message_service.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/jobs_screen_tab.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/map_screen.dart';
import 'dart:convert';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/notifications/notifications_for_user.dart';
import 'package:talent_link/widgets/login_widgets/login_page.dart';
import '../after_login_pages/home_page_tabs/profile_tab_sections/post_sections/post_creator.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  final String data; // Token
  final Function(String) onTokenChanged;

  const HomePage({super.key, required this.data, required this.onTokenChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final _logger = Logger();
  @override
  bool get wantKeepAlive => true;
  int _selectedIndex = 0;
  List<String> userSkills = [];
  List<String> userEducation = [];
  late MessageService _messageService;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _messageService = MessageService(widget.data);
  }

  Future<void> fetchUserData() async {
    const String apiUrl =
        "http://10.0.2.2:5000/api/skills/get-skills-education";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.data}",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userSkills = List<String>.from(data["skills"] ?? []);
          userEducation = List<String>.from(data["education"] ?? []);
        });
      } else {
        _logger.e("Failed to fetch data", error: response.statusCode);
      }
    } catch (e) {
      _logger.e("Error fetching data", error: e);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      fetchUserData();
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    widget.onTokenChanged('Unauthorized');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _handleSearchNavigation() {
    _messageService.navigateToSearchPage(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,

      child: Scaffold(
        resizeToAvoidBottomInset: true,

        appBar: AppBar(
          title: const Text(
            "Talent Link",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 49, 212, 63),
                  const Color.fromARGB(255, 68, 255, 224),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.message),
            onPressed: _handleSearchNavigation,
            color: Colors.white,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.blue[100]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              PostCreator(token: widget.data),
              JobsScreenTab(token: widget.data),
              MapScreen(token: widget.data),
              ProfileTab(token: widget.data, onLogout: _handleLogout),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.find_in_page),
              label: "Jobs",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: "Map",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
