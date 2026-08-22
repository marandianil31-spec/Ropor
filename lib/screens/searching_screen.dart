import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/match_service.dart';
import 'chat_screen.dart';

class SearchingScreen extends StatefulWidget {
  const SearchingScreen({super.key});

  @override
  State<SearchingScreen> createState() =>
      _SearchingScreenState();
}

class _SearchingScreenState
    extends State<SearchingScreen> {
  bool _isSearching = true;
  String _status =
      'Searching for a stranger...';

  StreamSubscription<DatabaseEvent>?
      _matchSubscription;

  bool _openingChat = false;

  @override
  void initState() {
    super.initState();

    _listenForMatch();
    _startSearching();
  }

  void _listenForMatch() {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    _matchSubscription = FirebaseDatabase
        .instance
        .ref()
        .child('waiting')
        .child(user.uid)
        .onValue
        .listen((event) async {
      final data = event.snapshot.value;

      if (data == null) return;

      if (data is Map &&
          data['matchedRoomId'] != null) {
        final roomId =
            data['matchedRoomId'].toString();

        if (roomId.isEmpty) return;
        if (_openingChat) return;

        _openingChat = true;

        await MatchService.leaveWaiting();

        await _openChat(roomId);
      }
    });
  }

  Future<void> _startSearching() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _status =
            'Unable to start matching';
      });

      return;
    }

    try {
      final roomId =
          await MatchService.startMatching();

      // Agar isi user ko direct match mil gaya
      if (roomId != null) {
        await _openChat(roomId);
        return;
      }

      if (!mounted) return;

      setState(() {
        _isSearching = true;
        _status =
            'Searching for a stranger...';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _status =
            'Matching failed. Please try again.';
      });
    }
  }

  Future<void> _openChat(String roomId) async {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(roomId: roomId),
      ),
    );
  }

  Future<void> _retry() async {
    if (!mounted) return;

    _openingChat = false;

    setState(() {
      _isSearching = true;
      _status =
          'Searching for a stranger...';
    });

    await MatchService.leaveWaiting();

    await _startSearching();
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                if (_isSearching)
                  const CircularProgressIndicator(),

                const SizedBox(height: 24),

                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                if (!_isSearching) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _retry,
                    child:
                        const Text('Retry'),
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
