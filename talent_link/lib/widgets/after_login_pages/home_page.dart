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
            "TalentLink",
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
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.message_outlined),
              onPressed: _handleSearchNavigation,
              color: Colors.white,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.05),
                Colors.white,
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey.shade600,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.find_in_page_outlined),
                activeIcon: Icon(Icons.find_in_page),
                label: "Jobs",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: "Map",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
