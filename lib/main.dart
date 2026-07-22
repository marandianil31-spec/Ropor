import 'services/auth_service.dart';
import 'screens/searching_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RoporChat());
}

class RoporChat extends StatelessWidget {
  const RoporChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Ropor Chat"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await
          AuthService.signInAnonymously();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const
            SearchingScreen(),
             ),
          },
          child: const Text("Start Random Chat"

        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Searching..."),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

