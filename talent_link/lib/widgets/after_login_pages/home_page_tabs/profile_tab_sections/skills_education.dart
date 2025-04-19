import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SkillsEducation extends StatefulWidget {
  final String token;
  const SkillsEducation({super.key, required this.token});

  @override
  State<SkillsEducation> createState() => SkillsEducationState();
}

class SkillsEducationState extends State<SkillsEducation> {
  List<String> userEducation = [];
  List<String> userSkills = [];
  bool _showAllSkills = false;
  bool _isLoadingSkills = false;
  bool _isLoadingEducation = false;

  Future<void> refreshSkills() async {
    setState(() => _isLoadingSkills = true);
    await fetchUserSkills();
    setState(() => _isLoadingSkills = false);
  }

  Future<void> refreshEducation() async {
    setState(() => _isLoadingEducation = true);
    await fetchUserEducation();
    setState(() => _isLoadingEducation = false);
  }

  Future<void> fetchUserSkills() async {
    setState(() => _isLoadingSkills = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/skills/get-all-skills'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final skillsData = data['skills'] ?? [];
        setState(() {
          userSkills = List<String>.from(skillsData);
        });
      } else {
        print('Failed to load skills');
      }
    } finally {
      setState(() => _isLoadingSkills = false);
    }
  }

  Future<void> fetchUserEducation() async {
    setState(() => _isLoadingEducation = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/skills/get-all-education'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final educationData = data['education'] ?? [];
        setState(() {
          userEducation = List<String>.from(educationData);
        });
      } else {
        print('Failed to load education');
      }
    } finally {
      setState(() => _isLoadingEducation = false);
    }
  }

  void showDeleteConfirmation(String item, String type) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to remove "$item"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (type == 'skill') {
                      userSkills.remove(item);
                    } else {
                      userEducation.remove(item);
                    }
                  });
                  deleteSkillOrEducation(type, item);
                  Navigator.pop(context);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> deleteSkillOrEducation(String type, String item) async {
    String url;
    Map<String, String> body;

    if (type == 'skill') {
      url = 'http://10.0.2.2:5000/api/skills/delete-skill';
      body = {'skill': item};
    } else if (type == 'education') {
      url = 'http://10.0.2.2:5000/api/skills/delete-education';
      body = {'education': item};
    } else {
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('$type deleted successfully');
      } else {
        print('Failed to delete $type: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting $type: $e');
    }
  }

  void showAddDialog({
    required String title,
    required String hint,
    required Function(String) onSubmit,
  }) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String value = controller.text.trim();
                if (value.isNotEmpty) {
                  onSubmit(value);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addSkillEducation(String url, String newItem) async {
    String operation;
    if (url.contains('add-skills')) {
      operation = 'skills';
    } else if (url.contains('add-education')) {
      operation = 'education';
    } else {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          operation: [newItem],
        }),
      );

      if (response.statusCode == 201) {
        print("$operation added successfully");
        if (operation == 'skills') {
          fetchUserSkills();
        } else {
          fetchUserEducation();
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (error) {
      print("Exception: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserEducation();
    fetchUserSkills();
  }

  @override
  Widget build(BuildContext context) {
    final skillsToShow =
        _showAllSkills ? userSkills : userSkills.take(3).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Education',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    userEducation
                        .map(
                          (edu) => Chip(
                            label: Text(edu),
                            backgroundColor: Colors.green.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            deleteIcon: Icon(Icons.close),
                            onDeleted:
                                () => showDeleteConfirmation(edu, 'education'),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
          child: FloatingActionButton.extended(
            heroTag: "education_fab",
            onPressed: () {
              showAddDialog(
                title: 'Education',
                hint: 'e.g. BSc in Computer Engineering',
                onSubmit: (value) {
                  addSkillEducation(
                    'http://10.0.2.2:5000/api/skills/add-education',
                    value,
                  );
                },
              );
            },
            label: Text("Add Education"),
            icon: Icon(Icons.add),
            backgroundColor: const Color(0xFF0C9E91),
            foregroundColor: Colors.white,
          ),
        ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 8)),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skills',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Add loading check here
              if (_isLoadingSkills)
                Center(child: CircularProgressIndicator())
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      skillsToShow
                          .map(
                            (skill) => Chip(
                              label: Text(skill),
                              backgroundColor: Colors.blue.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              deleteIcon: Icon(Icons.close),
                              onDeleted:
                                  () => showDeleteConfirmation(skill, 'skill'),
                            ),
                          )
                          .toList(),
                ),
              if (userSkills.length > 3 && !_isLoadingSkills)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllSkills = !_showAllSkills;
                    });
                  },
                  child: Text(_showAllSkills ? 'Show Less' : 'Show More'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
          child: FloatingActionButton.extended(
            heroTag: "skills_fab",
            onPressed: () {
              showAddDialog(
                title: 'Skill',
                hint: 'e.g. Flutter, Python, SQL',
                onSubmit: (value) {
                  addSkillEducation(
                    'http://10.0.2.2:5000/api/skills/add-skills',
                    value,
                  );
                },
              );
            },
            label: Text("Add Skill"),
            icon: Icon(Icons.add),
            backgroundColor: const Color(0xFF0C9E91),
            foregroundColor: Colors.white,
          ),
        ),
        Padding(padding: const EdgeInsets.only(bottom: 8)),
      ],
    );
  }
}
