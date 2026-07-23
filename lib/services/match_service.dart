import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MatchService {
  static final DatabaseReference db = FirebaseDatabase.instance.ref();

  static Future<void> joinQueue() async {
    final user = FirebaseAuth.instance.currentUser;

    print("USER: $user");

    if (user == null) {
      print("User is NULL");
      return;
    }

    try {
      await db.child("waiting").child(user.uid).set({
        "uid": user.uid,
        "time": ServerValue.timestamp,
      });

      print("Waiting node created successfully");
    } catch (e, s) {
      print("ERROR: $e");
      print(s);
    }
  }
}
