//new api all fixed i used api.env

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:talent_link/widgets/base_widgets/button.dart';
import 'package:url_launcher/url_launcher.dart';

final String baseUrl = dotenv.env['BASE_URL']!;

class Resume extends StatefulWidget {
  final String token;
  final VoidCallback onSkillsExtracted;

  const Resume({
    super.key,
    required this.token,
    required this.onSkillsExtracted,
  });

  @override
  State<Resume> createState() => _ResumeState();
}

class _ResumeState extends State<Resume> {
  String? uploadedCVUrl;
  bool _isUploading = false;

  Future<void> pickAndUploadPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      File pdfFile = File(result.files.single.path!);
      //192.168.1.7       final uri = Uri.parse("http://10.0.2.2:5000/api/users/upload-cv");

      final uri = Uri.parse("$baseUrl/users/upload-cv");

      final request = http.MultipartRequest("POST", uri);
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.files.add(await http.MultipartFile.fromPath('cv', pdfFile.path));

      setState(() {
        _isUploading = true;
      });

      try {
        final response = await request.send();

        if (response.statusCode == 200) {
          final resBody = await response.stream.bytesToString();
          final jsonResponse = json.decode(resBody);
          setState(() {
            uploadedCVUrl = jsonResponse['cvUrl'];
          });

          // Wait a moment for the backend to process the CV
          await Future.delayed(Duration(seconds: 1));

          // Force refresh skills and education
          widget.onSkillsExtracted();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CV uploaded successfully. Extracting skills...'),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to upload CV')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'CV / Resume',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          if (_isUploading) const LinearProgressIndicator(),

          const SizedBox(height: 10),

          if (uploadedCVUrl != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('CV.pdf', style: TextStyle(fontSize: 16)),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                    onPressed: () async {
                      final url = Uri.parse(uploadedCVUrl!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open CV')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        uploadedCVUrl = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('CV removed locally')),
                      );
                    },
                  ),
                ],
              ),
            )
          else
            BaseButton(
              text: "Upload CV (PDF)",
              onPressed: _isUploading ? () {} : pickAndUploadPDF,
            ),
        ],
      ),
    );
  }
}
