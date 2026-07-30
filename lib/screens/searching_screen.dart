import 'chat_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/match_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SearchingScreen extends StatefulWidget {
  const SearchingScreen({super.key});
  
  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();
StreamSubscription<DatabaseEvent>? _roomListener;
  @override
  void initState() {
    super.initState();

    _startMatching();
    _listenForRoom();
  }
@override
void dispose() {
  _roomListener?.cancel();
  super.dispose();
}
  Future<void> _startMatching() async {
  await MatchService.startMatching();
}
  
 void _listenForRoom() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  _roomListener = db.child("chatrooms").onValue.listen((event) {
    final data = event.snapshot.value;

    if (data == null || data is! Map) return;

    final rooms = Map<String, dynamic>.from(data);

    for (final roomEntry in rooms.entries) {
      final roomId = roomEntry.key;
      final room = Map<String, dynamic>.from(roomEntry.value);

      if (!room.containsKey("users")) continue;

      final users = Map<String, dynamic>.from(room["users"]);

      if (users.containsKey(user.uid)) {
        _roomListener?.cancel();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(roomId: roomId),
          ),
        );

        break;
      }
    }
  });
 } 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Searching..."),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "Searching for a stranger...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

