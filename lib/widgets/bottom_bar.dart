import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

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
              onPressed: () {
                // TODO: Attachment Menu
              },
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
                icon: Icon(
                  hasText ? Icons.send : Icons.sync,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (hasText) {
                    // TODO: Send Message
                  } else {
                    // TODO: Disconnect / Next
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
