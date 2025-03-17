import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String data;
  const HomePage({super.key, required this.data});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text("Home Screen")),
    const Center(child: Text("Jobs Screen")),
    const Center(child: Text("Maps Screen")),
    const Center(child: Text("Profile Screen")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("Talent Link")),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.black,
          fontSize: 23,
        ), // Change title as needed
        leading: IconButton(
          icon: const Icon(Icons.message), // Messages icon (top left)
          onPressed: () {
            // Handle messages click
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
            ), // Notifications icon (top right)
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
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
