import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Resume extends StatefulWidget {
  final String token;
  const Resume({super.key, required this.token});

  @override
  State<Resume> createState() => _ResumeState();
}

class _ResumeState extends State<Resume> {
  String? uploadedCVUrl;

  Future<void> pickAndUploadPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      File pdfFile = File(result.files.single.path!);
      final uri = Uri.parse("http://10.0.2.2:5000/api/users/upload-cv");

      final request = http.MultipartRequest("POST", uri);
      request.headers['Authorization'] = 'Bearer ${widget.token}';

      request.files.add(await http.MultipartFile.fromPath('cv', pdfFile.path));

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          final resBody = await response.stream.bytesToString();
          final jsonResponse = json.decode(resBody);
          setState(() {
            uploadedCVUrl = jsonResponse['cvUrl'];
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('CV uploaded successfully')));
        } else {
          print("Failed to upload CV: ${response.statusCode}");
        }
      } catch (e) {
        print("Upload error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CV / Resume',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          if (uploadedCVUrl != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Uploaded: ${uploadedCVUrl!.split('/').last}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: () {
                    // Open CV in browser or PDF viewer
                    launchUrl(Uri.parse(uploadedCVUrl!));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      uploadedCVUrl = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('CV removed locally')),
                    );
                    // Optional: also delete from backend
                  },
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: pickAndUploadPDF,
              icon: Icon(Icons.upload_file),
              label: Text("Upload CV (PDF)"),
            ),
        ],
      ),
    );
  }
}
