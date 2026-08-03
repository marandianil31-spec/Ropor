import 'package:firebase_database/firebase_database.dart';

class BlockService {
  static final DatabaseReference _db =
      FirebaseDatabase.instance.ref();

  static Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _db
        .child('blockedUsers')
        .child(currentUserId)
        .child(blockedUserId)
        .set({
      'blocked': true,
      'createdAt': ServerValue.timestamp,
    });
  }

  static Future<bool> isBlocked({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final snapshot = await _db
        .child('blockedUsers')
        .child(currentUserId)
        .child(otherUserId)
        .get();

    return snapshot.exists;
  }
}
