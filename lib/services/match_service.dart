import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'block_service.dart';

class MatchService {
  static final DatabaseReference db = FirebaseDatabase.instance.ref();

  static Future<void> startMatching() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final waitingRef = db.child('waiting');

    // Apni purani waiting entry hatao.
    await waitingRef.child(user.uid).remove();

    final waitingSnapshot = await waitingRef.get();

    if (waitingSnapshot.exists && waitingSnapshot.value is Map) {
      final data =
          Map<dynamic, dynamic>.from(waitingSnapshot.value as Map);

      // Available users ko ek-ek karke try karo.
      for (final entry in data.entries) {
        final firstUid = entry.key.toString();

        // Khud se match nahi hona chahiye.
        if (firstUid == user.uid) {
          continue;
        }

        // Kisi aur user ne already is user ko claim kiya ho to skip.
        final candidateData = entry.value;

        if (candidateData is Map &&
            candidateData['matched'] == true) {
          continue;
        }

        // Block check.
        final iBlockedThem = await BlockService.isBlocked(
          currentUserId: user.uid,
          otherUserId: firstUid,
        );

        if (iBlockedThem) {
          continue;
        }

        final theyBlockedMe = await BlockService.isBlocked(
          currentUserId: firstUid,
          otherUserId: user.uid,
        );

        if (theyBlockedMe) {
          continue;
        }

        // Candidate ko atomically claim karo.
        final candidateRef = waitingRef.child(firstUid);

        final transaction =
            await candidateRef.runTransaction((currentData) {
          if (currentData == null) {
            return Transaction.abort();
          }

          if (currentData is Map &&
              currentData['matched'] == true) {
            return Transaction.abort();
          }

          final currentMap =
              Map<dynamic, dynamic>.from(currentData as Map);

          currentMap['matched'] = true;
          currentMap['matchedBy'] = user.uid;

          return Transaction.success(currentMap);
        });

        if (!transaction.committed) {
          continue;
        }

        // Match successful: room create karo.
        final roomId = db.child('chatrooms').push().key;

        if (roomId == null) {
          await candidateRef.child('matched').remove();
          await candidateRef.child('matchedBy').remove();
          continue;
        }

        await db.child('chatrooms').child(roomId).set({
          'roomId': roomId,
          'users': {
            firstUid: true,
            user.uid: true,
          },
          'createdAt': ServerValue.timestamp,
        });

        // Waiting se matched user ko remove karo.
        await candidateRef.remove();

        return;
      }
    }

    // Koi suitable user nahi mila.
    // Khud ko waiting list mein daalo.
    await waitingRef.child(user.uid).set({
      'time': ServerValue.timestamp,
    });
  }

  static Future<String?> getOtherUserId(String roomId) async {
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

    final roomRef = db.child('chatrooms').child(roomId);

    await roomRef.child('users').child(user.uid).remove();

    final usersSnapshot =
        await roomRef.child('users').get();

    if (!usersSnapshot.exists ||
        usersSnapshot.value == null) {
      await roomRef.remove();
    }
  }
}
