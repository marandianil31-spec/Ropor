import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/top_bar.dart';
import '../widgets/warning_card.dart';
import '../widgets/message_bubble.dart';
import '../widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  
  const ChatScreen({
    super.key,
    required this.roomId,});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: const TopBar(),
  backgroundColor: AppTheme.background,
  body: Column(
    children: [
      const WarningCard(),

      const Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MessageBubble(
                message: "Hello 👋",
                isMe: false,
              ),
              MessageBubble(
                message: "Hi! How are you?",
                isMe: true,
              ),
            ],
          ),
        ),
      ),

    BottomBar(
  onSend: (text) async {
    await _chatService.sendMessage(
      roomId: widget.roomId,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      text: text,
    );
  },
),
    ],
  ),
);
  }
}
