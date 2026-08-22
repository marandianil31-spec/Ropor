import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'block_service.dart';

class MatchService {
  static final DatabaseReference db = FirebaseDatabase.instance.ref();

  static Future<String?> startMatching() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final waitingRef = db.child('waiting');
    final snapshot = await waitingRef.get();

    if (snapshot.exists && snapshot.value != null) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (final entry in data.entries) {
        final firstUid = entry.key.toString();

        // Khud ko match mat karo
        if (firstUid == user.uid) {
          continue;
        }

        final value = entry.value;

        // Already matched user ko skip karo
        if (value is Map &&
            value['matchedRoomId'] != null) {
          continue;
        }

        final iBlockedThem = await BlockService.isBlocked(
          currentUserId: user.uid,
          otherUserId: firstUid,
        );

        final theyBlockedMe = await BlockService.isBlocked(
          currentUserId: firstUid,
          otherUserId: user.uid,
        );

        if (iBlockedThem || theyBlockedMe) {
          await waitingRef.child(firstUid).remove();
          continue;
        }

        final roomId =
            db.child('chatrooms').push().key;

        if (roomId == null) return null;

        // Chat room create
        await db.child('chatrooms').child(roomId).set({
          'roomId': roomId,
          'users': {
            firstUid: true,
            user.uid: true,
          },
          'createdAt': ServerValue.timestamp,
        });

        // Waiting user ko roomId batao
        await waitingRef.child(firstUid).update({
          'matchedRoomId': roomId,
        });

        return roomId;
      }
    }

    // Koi stranger nahi mila
    await waitingRef.child(user.uid).set({
      'time': ServerValue.timestamp,
    });

    // App/network disconnect hone par waiting entry hata dena
    await waitingRef.child(user.uid).onDisconnect().remove();

    return null;
  }

  static Future<String?> getOtherUserId(
    String roomId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final snapshot = await db
        .child('chatrooms')
        .child(roomId)
        .child('users')
        .get();

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final users =
        snapshot.value as Map<dynamic, dynamic>;

    for (final uid in users.keys) {
      final id = uid.toString();

      if (id != user.uid) {
        return id;
      }
    }

    return null;
  }

  static Future<void> leaveWaiting() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await db
        .child('waiting')
        .child(user.uid)
        .remove();
  }

  static Future<void> leaveRoom(String roomId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final roomRef =
        db.child('chatrooms').child(roomId);

    await roomRef
        .child('users')
        .child(user.uid)
        .remove();

    final usersSnapshot =
        await roomRef.child('users').get();

    if (!usersSnapshot.exists ||
        usersSnapshot.value == null) {
      await roomRef.remove();
    }
  }
}
