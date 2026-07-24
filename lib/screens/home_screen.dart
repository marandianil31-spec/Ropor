
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'searching_screen.dart';

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
            await AuthService.signInAnonymously();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchingScreen(),
              ),
            );
          },
          child: const Text("Start Random Chat"),
        ),
      ),
    );
  }
}
