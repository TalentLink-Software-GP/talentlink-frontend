import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class AvatarName extends StatefulWidget {
  final String token;
  const AvatarName({super.key, required this.token});

  @override
  State<AvatarName> createState() => _AvatarNameState();
}

class _AvatarNameState extends State<AvatarName> {
  String? uploadedImageUrl;
  String name = '';
  String industry = '';
  @override
  void initState() {
    super.initState();
    fetchOrgData();
  }

  Future<void> fetchOrgData() async {
    try {
      final uri = Uri.parse("http://10.0.2.2:5000/api/organization/getOrgData");

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          uploadedImageUrl = jsonResponse['avatarUrl'];
          name = jsonResponse['name'];
          industry = jsonResponse['industry'];
        });
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<String?> uploadImageToBackend(File imageFile) async {
    final uri = Uri.parse("http://10.0.2.2:5000/api/organization/updateAvatar");

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

  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<void> removeAvatarFromBackend() async {
    final uri = Uri.parse("http://10.0.2.2:5000/api/organization/deleteAvatar");

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 120,
        child: Card(
          color: Colors.white70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: FloatingActionButton(
                  heroTag: "avatar_fab",
                  onPressed: showAvatarOptions,
                  shape: CircleBorder(),
                  elevation: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage:
                        uploadedImageUrl != null
                            ? NetworkImage(uploadedImageUrl!)
                            : AssetImage('assets/images/avatarPlaceholder.jpg')
                                as ImageProvider,
                    radius: 999999,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(industry, style: TextStyle(color: Colors.blueGrey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
