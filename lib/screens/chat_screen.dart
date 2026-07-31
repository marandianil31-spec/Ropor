import '../services/match_service.dart';
import 'searching_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/top_bar.dart';
import '../widgets/warning_card.dart';
import '../widgets/message_bubble.dart';
import '../widgets/bottom_bar.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;

  const ChatScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
  onReport: () {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Report User"),
          content: const Text(
            "Do you want to report this user?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Report submitted"),
                  ),
                );
              },
              child: const Text("Report"),
            ),
          ],
        );
      },
    );
  },
  onNext: () async {
    await MatchService.leaveRoom(widget.roomId);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchingScreen(),
      ),
    );
  },
),
