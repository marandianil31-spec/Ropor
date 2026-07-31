import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  final Function(String) onSend;
final VoidCallback onNext;

const BottomBar({
  super.key,
  required this.onSend,
  required this.onNext,
});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool hasText = controller.text.trim().isNotEmpty;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {},
            ),

            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            CircleAvatar(
  radius: 24,
  backgroundColor: Colors.deepPurple,
  child: IconButton(
    icon: const Icon(
      Icons.attach_file,
      color: Colors.white,
    ),
    onPressed: () {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Camera"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Gallery"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.mic),
                  title: const Text("Voice Message"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.call),
                  title: const Text("Audio Call"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text("Video Call"),
                  onTap: () => Navigator.pop(context),
          ],
        ),
      ),
    );
  }
  }
