import 'package:flutter/material.dart';
import 'package:talent_link/widgets/base_widgets/button.dart';

class ProfileTab extends StatelessWidget {
  final List<String> userEducation;
  final List<String> userSkills;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.userEducation,
    required this.userSkills,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Education",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          userEducation.isEmpty
              ? const Text("No education details added.")
              : Column(
                children: userEducation.map((edu) => Text(edu)).toList(),
              ),
          BaseButton(text: "Add Education", onPressed: () {}),

          const Text(
            "User Skills",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          userSkills.isEmpty
              ? const Text("No skills added.")
              : Column(
                children: userSkills.map((skill) => Text(skill)).toList(),
              ),
          BaseButton(text: "Add Skill", onPressed: () {}),

          const SizedBox(height: 20),
          BaseButton(
            text: "Log Out",
            buttonColor: Colors.red,
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
