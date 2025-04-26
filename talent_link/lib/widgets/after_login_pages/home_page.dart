import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab.dart';
// import 'package:talent_link/widgets/after_login_pages/home_page_tabs/user_posts.dart';
import 'package:talent_link/widgets/login_widgets/login_page.dart';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab_sections/mesageProfile.dart';
import '../after_login_pages/home_page_tabs/profile_tab_sections/post_sections/post_creator.dart';

class HomePage extends StatefulWidget {
  String data; // Token
  HomePage({super.key, required this.data});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int _selectedIndex = 0;
  List<String> userSkills = [];
  List<String> userEducation = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      fetchUserData();
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    setState(() {
      widget.data = 'Unauthorized';
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> navigateToSearchPage() async {
    const userApiUrl = 'http://10.0.2.2:5000/api/users/get-user-id';

    try {
      final response = await http.get(
        Uri.parse(userApiUrl),
        headers: {"Authorization": "Bearer ${widget.data}"},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final String userId = userData['userId'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchUserPage(currentUserId: userId),
          ),
        );
      } else {
        print("Failed to fetch user ID");
      }
    } catch (e) {
      print("Error navigating to search page: $e");
    }
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
            onPressed: navigateToSearchPage,
            color: Colors.white,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
              color: Colors.white,
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
              const Center(
                child: Text(
                  "Jobs Screen",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const Center(
                child: Text(
                  "Maps Screen",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              ProfileTab(
                token: widget.data,
                userEducation: userEducation,
                userSkills: userSkills,
                onLogout: _handleLogout,
              ),
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
