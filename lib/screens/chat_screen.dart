import 'package:firebase_auth/firebase_auth.dart';
import '../services/report_service.dart';
import '../services/block_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/match_service.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/top_bar.dart';
import '../widgets/warning_card.dart';
import '../widgets/message_bubble.dart';
import '../widgets/bottom_bar.dart';

import 'searching_screen.dart';

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
    StreamSubscription<DatabaseEvent>? _roomSubscription;
  bool _containsBlockedContact(String text) {
    final String value = text.toLowerCase();

    final RegExp emailRegex = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+[.][a-zA-Z]{2,}',
    );

    final RegExp phoneRegex = RegExp(
      r'[0-9]{8,15}',
    );

    final RegExp socialRegex = RegExp(
      r'instagram|insta|whatsapp|telegram|facebook|snapchat',
      caseSensitive: false,
    );

    return emailRegex.hasMatch(value) ||
        phoneRegex.hasMatch(value) ||
        socialRegex.hasMatch(value);
  }

  Future<void> _blockCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final otherUserId =
        await MatchService.getOtherUserId(widget.roomId);

    if (otherUserId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found'),
        ),
      );
      return;
    }

    await BlockService.blockUser(
      currentUserId: currentUser.uid,
      blockedUserId: otherUserId,
    );
    await _roomSubscription?.cancel();
    await MatchService.leaveRoom(widget.roomId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User blocked'),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchingScreen(),
      ),
    );
  }

  Future<void> _nextUser() async {
    await _roomSubscription?.cancel();
    await MatchService.leaveRoom(widget.roomId);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchingScreen(),
      ),
    );
  }
  void _listenForDisconnect() {
  _roomSubscription = FirebaseDatabase.instance
      .ref()
      .child('chatrooms')
      .child(widget.roomId)
      .child('users')
      .onValue
      .listen((event) async {
    final data = event.snapshot.value;

    if (data == null) {
      return;
    }

    final users = data as Map<dynamic, dynamic>;

    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    if (!users.containsKey(currentUser.uid) ||
        users.length < 2) {
      await _roomSubscription?.cancel();
      await MatchService.leaveRoom(widget.roomId);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SearchingScreen(),
        ),
      );
    }
  });
  }
  @override
void initState() {
  super.initState();
  _listenForDisconnect();
}
  Future<void> _handleBack() async {
  await _roomSubscription?.cancel();
  await MatchService.leaveRoom(widget.roomId);

  if (!mounted) return;

  Navigator.pop(context);
  }
  @override
  return PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    await _handleBack();
  },
  child: Scaffold(
    );
    }
    
      appBar: TopBar(
        onReport: () {
          showDialog(
            context: context,
            builder: (dialogContext) {
              return SimpleDialog(
                title: const Text(
                  'Why are you reporting this user?',
                ),
                children: [
                  'Harassment',
                  'Abusive Language',
                  'Spam',
                  'Sexual Content',
                  'Sharing Contact Info',
                  'Other',
                ].map((reason) {
                  return SimpleDialogOption(
                    onPressed: () async {
                      final user =
                          FirebaseAuth.instance.currentUser;

                      if (user == null) return;

                      await ReportService.submitReport(
                        reporterId: user.uid,
                        roomId: widget.roomId,
                        reason: reason,
                      );

                      if (!mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Report submitted: $reason'),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: Text(reason),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
        onBlock: _blockCurrentUser,
        onNext: _nextUser,
      ),
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          const WarningCard(),

          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream:
                  _chatService.messageStream(widget.roomId),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
    snapshot.data!.snapshot.value == null) {
  return const Center(
    child: Text('No messages yet'),
  );
                }

                final data =
                    snapshot.data!.snapshot.value
                        as Map<dynamic, dynamic>;

                final messages = data.entries.toList();

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].value;

                    return MessageBubble(
                      message: msg['text'] ?? '',
                      isMe: msg['senderId'] ==
                          FirebaseAuth
                              .instance
                              .currentUser
                              ?.uid,
                    );
                  },
                );
              },
            ),
          ),

          BottomBar(
            onSend: (text) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  if (_containsBlockedContact(text)) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Sharing phone numbers, email addresses and social media contacts is not allowed.',
        ),
      ),
    );

    return;
  }

  await _chatService.sendMessage(
    roomId: widget.roomId,
    senderId: user.uid,
    text: text,
  );
},

            onPhotoSend: (filePath) async {
              final user =
                  FirebaseAuth.instance.currentUser;

              if (user == null) return;

              await _chatService.sendPhoto(
                roomId: widget.roomId,
                senderId: user.uid,
                filePath: filePath,
              );
            },

            onNext: _nextUser,
          ),
        ],
      ),
    );
    }
 @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }
}
