import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MatchService {
  static final DatabaseReference db = FirebaseDatabase.instance.ref();

  static Future<void> joinQueue() async {
    final user = FirebaseAuth.instance.currentUser;

    print("USER UID: $user.uid}");

    if (user == null) {
      print("User is NULL");
      return;
    }

    try {
      print("Writing to Firebase...");
      
      await db.child("waiting").child(user.uid).set({
        "uid": user.uid,
        "time": ServerValue.timestamp,
      });
     print("WRITE SUCCESS");
      
      print("Waiting node created successfully");
    } catch (e, s) {
      print("ERROR: $e");
      print(s);
    }
  }
}
