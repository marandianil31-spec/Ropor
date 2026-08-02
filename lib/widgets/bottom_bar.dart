import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  final Function(String) onSend;
final Function(String) onPhotoSend;
final VoidCallback onNext;

  const BottomBar({
  super.key,
  required this.onSend,
  required this.onPhotoSend,
  required this.onNext,
});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final TextEditingController controller = TextEditingController();
final ImagePicker _picker = ImagePicker();

Future<void> _takePhoto() async {
  try {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo == null) return;

    await widget.onPhotoSend(photo.path);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo sent'),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo send error: $e'),
      ),
    );
  }
}
  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera Photo'),
               onTap: () {
  Navigator.pop(sheetContext);
  _takePhoto();
}, 
),                

              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery Photo'),
                onTap: () {
                  Navigator.pop(sheetContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gallery Photo - coming next'),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Camera Video'),
                onTap: () {
                  Navigator.pop(sheetContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Camera Video - coming next'),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Gallery Video'),
                onTap: () {
                  Navigator.pop(sheetContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gallery Video - coming next'),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('Voice Message'),
                onTap: () {
                  Navigator.pop(sheetContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voice Message - coming next'),
                    ),
                  );
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.call),
                title: const Text('Audio Call - VIP'),
                trailing: const Icon(Icons.workspace_premium),
                onTap: () {
                  Navigator.pop(sheetContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Audio Call is a VIP feature'),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.video_call),
                title: const Text('Video Call - VIP'),
                trailing: const Icon(Icons.workspace_premium),
                onTap: () {
                  Navigator.pop(sheetContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Video Call is a VIP feature'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage() {
    final text = controller.text.trim();

    if (text.isEmpty) {
      widget.onNext();
      return;
    }

    widget.onSend(text);

    controller.clear();

    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = controller.text.trim().isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _showAttachmentMenu,
            ),

            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (_) {
                  setState(() {});
                },
                onSubmitted: (_) {
                  if (hasText) {
                    _sendMessage();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Type a message...',
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
                  hasText ? Icons.send : Icons.skip_next,
                  color: Colors.white,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
