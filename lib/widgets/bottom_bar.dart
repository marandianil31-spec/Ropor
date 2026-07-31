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
    final hasText = controller.text.trim().isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
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
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (_) => setState(() {}),
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
                    widget.onSend(controller.text.trim());
                    controller.clear();
                    setState(() {});
                  } else {
                    widget.onNext();
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
