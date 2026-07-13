import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<User?> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user;
  }
}

