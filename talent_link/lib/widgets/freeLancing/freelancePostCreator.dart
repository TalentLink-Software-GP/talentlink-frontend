import 'package:flutter/material.dart';

class FreelancePostCreator extends StatefulWidget {
  final Function(String) onPost;

  const FreelancePostCreator({required this.onPost, super.key});

  @override
  _FreelancePostCreatorState createState() => _FreelancePostCreatorState();
}

class _FreelancePostCreatorState extends State<FreelancePostCreator> {
  final TextEditingController _controller = TextEditingController();

  void _handlePost() {
    final content = _controller.text.trim();
    if (content.isNotEmpty) {
      widget.onPost(content);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Describe your freelance project...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _handlePost,
              child: const Text("Post Freelance Request"),
            ),
          ],
        ),
      ),
    );
  }
}
