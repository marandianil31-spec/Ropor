import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MatchService {
  static final DatabaseReference db = FirebaseDatabase.instance.ref();

  static Future<void> startMatching() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final waitingRef = db.child("waiting");

    final waitingSnapshot = await waitingRef.get();

    if (waitingSnapshot.exists) {
      final data = waitingSnapshot.value as Map;

      if (data.isNotEmpty) {
        final firstUid = data.keys.first.toString();

        if (firstUid != user.uid) {
          final roomId = db.child("chatrooms").push().key!;

          await db.child("chatrooms").child(roomId).set({
  "roomId": roomId,
  "users": {
    firstUid: true,
    user.uid: true,
  },
  "createdAt": ServerValue.timestamp,
});

          await waitingRef.child(firstUid).remove();

          return;
        }
      }
    }
        await waitingRef.child(user.uid).set({
      "time": ServerValue.timestamp,
    });
  }
static Future<String?> getOtherUserId(String roomId) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return null;

  final snapshot = await db
      .child("chatrooms")
      .child(roomId)
      .child("users")
      .get();

  if (!snapshot.exists || snapshot.value == null) {
    return null;
  }

  final users = snapshot.value as Map<dynamic, dynamic>;

  for (final uid in users.keys) {
    final id = uid.toString();

    if (id != user.uid) {
      return id;
    }
  }

  return null;
}
  
  static Future<void> leaveRoom(String roomId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final roomRef = db.child("chatrooms").child(roomId);

    await roomRef.child("users").child(user.uid).remove();

    await db.child("waiting").child(user.uid).set({
      "time": ServerValue.timestamp,
    });
  }
}
