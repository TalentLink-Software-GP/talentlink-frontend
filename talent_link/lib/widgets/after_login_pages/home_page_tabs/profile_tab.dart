import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfileTab extends StatefulWidget {
  final List<String> userEducation;
  final List<String> userSkills;
  final VoidCallback onLogout;
  final String token;

  const ProfileTab({
    super.key,
    required this.userEducation,
    required this.userSkills,
    required this.onLogout,
    required this.token,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  List<String> userSkills = [];
  List<String> userEducation = [];
  String? uploadedImageUrl;
  @override
  void initState() {
    super.initState();
    fetchUserSkills();
    fetchUserEducation();
    fetchUserData();
  }

  void showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.remove_red_eye),
                title: Text('View Profile Picture'),
                onTap: () {
                  Navigator.pop(context);
                  if (uploadedImageUrl != null) {
                    showDialog(
                      context: context,
                      builder:
                          (_) =>
                              Dialog(child: Image.network(uploadedImageUrl!)),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.update),
                title: Text('Update Profile Picture'),
                onTap: () async {
                  Navigator.pop(context);
                  File? image = await pickImage();
                  if (image != null) {
                    String? imageUrl = await uploadImageToBackend(image);
                    if (imageUrl != null) {
                      setState(() {
                        uploadedImageUrl = imageUrl;
                      });
                    }
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove Profile Picture'),
                onTap: () async {
                  Navigator.pop(context);
                  await removeAvatarFromBackend();
                },
              ),
            ],
          ),
    );
  }

  Future<void> fetchUserData() async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    String username = decodedToken['username'];

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/users/getUserData?userName=$username',
        ),
        headers: {'Content-Type': 'application/json'},
      );
      print(username);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          uploadedImageUrl = data['avatarUrl'];
        });
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
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

        // Refresh the list after adding
        if (operation == 'skills') {
          fetchUserSkills();
        } else if (operation == 'education') {
          fetchUserEducation();
        }
      } else if (response.statusCode == 400) {
        print("Invalid input");
      } else {
        print("Unexpected error: ${response.statusCode}");
      }
    } catch (error) {
      print("Exception: $error");
    }
  }

  Future<void> fetchUserEducation() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/skills/get-all-education'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> educationData = data['education'] ?? [];
      print("Education: $educationData");
      setState(() {
        userEducation = educationData.map((e) => e.toString()).toList();
      });
    } else {
      print('Failed to load education');
    }
  }

  Future<void> fetchUserSkills() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/skills/get-all-skills'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> skillsData = data['skills'] ?? [];
      print("Skills: $skillsData");
      setState(() {
        userSkills = skillsData.map((e) => e.toString()).toList();
      });
    } else {
      print('Failed to load skills');
    }
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
                  Navigator.of(context).pop(); // close dialog
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> uploadImageToBackend(File imageFile) async {
    final uri = Uri.parse("http://10.0.2.2:5000/api/users/upload-avatar");

    final request = http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    request.files.add(
      await http.MultipartFile.fromPath('avatar', imageFile.path),
    );

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(resBody);
        return jsonResponse['avatarUrl'];
      } else {
        print("Failed to upload: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Future<void> removeAvatarFromBackend() async {
    final uri = Uri.parse("http://10.0.2.2:5000/api/users/remove-avatar");

    try {
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          uploadedImageUrl = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile picture removed')));
      } else {
        print("Failed to delete avatar: ${response.statusCode}");
      }
    } catch (e) {
      print("Delete avatar error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.minHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar & Username
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: FloatingActionButton(
                            heroTag: "avatar_fab",
                            onPressed: showAvatarOptions,
                            shape: CircleBorder(),
                            elevation: 10,
                            child: CircleAvatar(
                              backgroundImage:
                                  uploadedImageUrl != null
                                      ? NetworkImage(uploadedImageUrl!)
                                      : AssetImage(
                                            'assets/images/avatarPlaceholder.jpg',
                                          )
                                          as ImageProvider,
                              radius: 999999,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      decodedToken['username'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on),
                            SizedBox(width: 8),
                            Text('Location'),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.work),
                            SizedBox(width: 8),
                            Text('Hired'),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.group),
                            SizedBox(width: 8),
                            Text('Connections'),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Education',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                userEducation.map((edu) {
                                  return Chip(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    label: Text(edu),
                                    deleteIcon: Icon(Icons.close),
                                    onDeleted:
                                        () => showDeleteConfirmation(
                                          edu,
                                          'education',
                                        ),
                                    backgroundColor: Colors.green.shade100,
                                  );
                                }).toList(),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                userSkills.map((skill) {
                                  return Chip(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    label: Text(skill),
                                    deleteIcon: Icon(Icons.close),
                                    onDeleted:
                                        () => showDeleteConfirmation(
                                          skill,
                                          'skill',
                                        ),
                                    backgroundColor: Colors.blue.shade100,
                                  );
                                }).toList(),
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
                    Divider(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
