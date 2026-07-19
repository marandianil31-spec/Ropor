import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MatchService {
  static final DatabaseReference db =
      FirebaseDatabase.instance.ref();

  static Future<void> joinQueue() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await db.child("waiting").child(user.uid).set({
      "uid": user.uid,
      "time": ServerValue.timestamp,
    });
  }
}
