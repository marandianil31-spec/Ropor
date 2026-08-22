import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'block_service.dart';

class MatchService {
  static final DatabaseReference db =
      FirebaseDatabase.instance.ref();

  // =========================
  // START MATCHING
  // =========================
  static Future<String?> startMatching() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final myUid = user.uid;
    final waitingRef = db.child('waiting');

    final snapshot = await waitingRef.get();

    if (snapshot.exists && snapshot.value != null) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      for (final entry in data.entries) {
        final strangerUid = entry.key.toString();

        // Khud se match nahi karna
        if (strangerUid == myUid) {
          continue;
        }

        final strangerData = entry.value;

        // Agar stranger already kisi ke saath match ho chuka hai
        if (strangerData is Map &&
            strangerData['matchedRoomId'] != null) {
          continue;
        }

        // Block check
        final iBlockedThem =
            await BlockService.isBlocked(
          currentUserId: myUid,
          otherUserId: strangerUid,
        );

        final theyBlockedMe =
            await BlockService.isBlocked(
          currentUserId: strangerUid,
          otherUserId: myUid,
        );

        if (iBlockedThem || theyBlockedMe) {
          await waitingRef
              .child(strangerUid)
              .remove();

          continue;
        }

        // =========================
        // CREATE CHAT ROOM
        // =========================

        final roomId =
            db.child('chatrooms').push().key;

        if (roomId == null) {
          return null;
        }

        await db
            .child('chatrooms')
            .child(roomId)
            .set({
          'roomId': roomId,
          'users': {
            strangerUid: true,
            myUid: true,
          },
          'createdAt': ServerValue.timestamp,
        });

        // =========================
        // FIRST USER KO ROOM ID
        // =========================

        await waitingRef
            .child(strangerUid)
            .update({
          'matchedRoomId': roomId,
        });

        // Apna waiting node ensure karo
        await waitingRef
            .child(myUid)
            .remove();

        return roomId;
      }
    }

    // =========================
    // KOI STRANGER NAHI MILA
    // =========================

    // Pehle disconnect handler set karo
    await waitingRef
        .child(myUid)
        .onDisconnect()
        .remove();

    // Phir waiting me add karo
    await waitingRef
        .child(myUid)
        .set({
      'time': ServerValue.timestamp,
    });

    return null;
  }

  // =========================
  // GET OTHER USER
  // =========================

  static Future<String?> getOtherUserId(
    String roomId,
  ) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final snapshot = await db
        .child('chatrooms')
        .child(roomId)
        .child('users')
        .get();

    if (!snapshot.exists ||
        snapshot.value == null) {
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

  // =========================
  // LEAVE WAITING
  // =========================

  static Future<void> leaveWaiting() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await db
        .child('waiting')
        .child(user.uid)
        .remove();
  }

  // =========================
  // LEAVE CHAT ROOM
  // =========================

  static Future<void> leaveRoom(
    String roomId,
  ) async {
    final user =
        FirebaseAuth.instance.currentUser;

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
