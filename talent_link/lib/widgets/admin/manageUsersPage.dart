// manage_users_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String baseUrl = dotenv.env['BASE_URL']!;

class ManageUsersPage extends StatefulWidget {
  final String token;

  const ManageUsersPage({super.key, required this.token});

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  List users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers({String? type}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/users?type=$type'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    setState(() {
      users = jsonDecode(res.body);
    });
  }

  Future<void> banUser(String id) async {
    await http.put(
      Uri.parse('$baseUrl/admin/users/$id/ban'),
      headers: {'Authorization': 'Bearer your_admin_token'},
    );
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  fetchUsers(type: 'user');
                },
                child: const Text('Users'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  fetchUsers(type: 'org');
                },
                child: const Text('Organizations'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 👇 List of users/orgs
          Expanded(
            child:
                users.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (_, index) {
                        final user = users[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(user['name'] ?? user['username']),
                          subtitle: Text(user['email']),
                          trailing: ElevatedButton(
                            onPressed: () => banUser(user['_id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Ban'),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
