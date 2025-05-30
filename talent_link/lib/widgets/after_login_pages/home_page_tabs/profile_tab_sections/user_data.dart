import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_link/services/application_service.dart';
import 'package:talent_link/utils/pdfViewr.dart';

class UserData extends StatelessWidget {
  const UserData({super.key});
  Future<String> getCurrentUserid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? 'defaultUsername';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Icon(Icons.location_on),
            SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                final userId = await getCurrentUserid();

                if (userId != null) {
                  final cvUrl = await ApplicationService.getUserCV(userId);
                  if (cvUrl != null && cvUrl.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFViewerPage(url: cvUrl),
                      ),
                    );
                  } else {
                    print('No CV URL found');
                  }
                } else {
                  print("application.userId is null!");
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "View Cv",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
