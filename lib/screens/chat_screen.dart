import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  
  const Chatscreen({
    super.key,
    required this.roomId,});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stranger"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.flag),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.skip_next),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text("Connected with Stranger"),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.emoji_emotions),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.attach_file),
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mic),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
