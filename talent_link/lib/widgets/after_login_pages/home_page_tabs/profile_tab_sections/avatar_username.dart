import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AvatarUsername extends StatefulWidget {
  final String token;
  const AvatarUsername({super.key, required this.token});

  @override
  State<AvatarUsername> createState() => _AvatarUsernameState();
}

class _AvatarUsernameState extends State<AvatarUsername> {
  String? uploadedImageUrl;

  @override
  @override
  void initState() {
    super.initState();
    fetchUserData();
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

  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
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
    return Column(
      children: [
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
                          : AssetImage('assets/images/avatarPlaceholder.jpg')
                              as ImageProvider,
                  radius: 999999,
                ),
              ),
            ),
          ),
        ),
        Text(
          decodedToken['username'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
