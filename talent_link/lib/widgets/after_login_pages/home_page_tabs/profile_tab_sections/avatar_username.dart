import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';

class AvatarUsername extends StatefulWidget {
  final String token;
  const AvatarUsername({super.key, required this.token});

  @override
  State<AvatarUsername> createState() => _AvatarUsernameState();
}

class _AvatarUsernameState extends State<AvatarUsername> {
  String? uploadedImageUrl;
  final _logger = Logger();

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
      _logger.i('Fetching data for user: $username');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          uploadedImageUrl = data['avatarUrl'];
        });
      } else {
        _logger.e('Failed to fetch user data:', error: response.statusCode);
      }
    } catch (e) {
      _logger.e('Error fetching user data:', error: e);
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
        _logger.e('Failed to upload:', error: response.statusCode);
        return null;
      }
    } catch (e) {
      _logger.e('Upload error:', error: e);
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
        _logger.e('Failed to delete avatar:', error: response.statusCode);
      }
    } catch (e) {
      _logger.e('Delete avatar error:', error: e);
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
