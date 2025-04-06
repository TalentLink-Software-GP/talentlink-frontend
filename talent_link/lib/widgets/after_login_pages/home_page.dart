// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:talent_link/widgets/after_login_pages/home_page_tabs/profile_tab.dart';
import 'package:talent_link/widgets/login_widgets/login_page.dart';

class HomePage extends StatefulWidget {
  String data; // Token
  HomePage({super.key, required this.data});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        // ignore: avoid_print
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      // ignore: avoid_print
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Talent Link")),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.black,
          fontSize: 23,
        ),
        leading: IconButton(icon: const Icon(Icons.message), onPressed: () {}),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const Center(child: Text("Home Screen")),
          const Center(child: Text("Jobs Screen")),
          const Center(child: Text("Maps Screen")),
          ProfileTab(
            token: widget.data,
            userEducation: userEducation,
            userSkills: userSkills,
            onLogout: _handleLogout,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.find_in_page),
            label: "Jobs",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
