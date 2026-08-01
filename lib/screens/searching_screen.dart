import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/match_service.dart';
import 'chat_screen.dart';

class SearchingScreen extends StatefulWidget {
  const SearchingScreen({super.key});

  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  StreamSubscription<DatabaseEvent>? _roomsSubscription;

  bool _isSearching = true;
  String _status = 'Searching for a stranger...';

  @override
  void initState() {
    super.initState();
    _startSearching();
  }

  Future<void> _startSearching() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _status = 'Unable to start matching';
      });

      return;
    }

    await _roomsSubscription?.cancel();

    _roomsSubscription =
        _db.child('chatrooms').onValue.listen((DatabaseEvent event) {
      final value = event.snapshot.value;

      if (value == null || value is! Map) {
        return;
      }

      for (final entry in value.entries) {
        final roomId = entry.key.toString();
        final roomData = entry.value;

        if (roomData is! Map) {
          continue;
        }

        final users = roomData['users'];

        if (users is Map && users.containsKey(user.uid)) {
          _openChat(roomId);
          return;
        }
      }
    });

    try {
      await MatchService.startMatching();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _status = 'Matching failed. Please try again.';
      });
    }
  }

  Future<void> _openChat(String roomId) async {
    await _roomsSubscription?.cancel();
    _roomsSubscription = null;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(roomId: roomId),
      ),
    );
  }

  Future<void> _retry() async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _status = 'Searching for a stranger...';
    });

    await _startSearching();
  }

  @override
  void dispose() {
    _roomsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSearching)
                  const CircularProgressIndicator(),

                const SizedBox(height: 24),

                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (!_isSearching) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
