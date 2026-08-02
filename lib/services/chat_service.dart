import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DatabaseReference messagesRef(String roomId) {
    return _db.child("chatrooms").child(roomId).child("messages");
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
  }) async {
    await messagesRef(roomId).push().set({
      "senderId": senderId,
      "type": "text",
      "text": text,
      "timestamp": ServerValue.timestamp,
    });
  }

  Future<void> sendPhoto({
    required String roomId,
    required String senderId,
    required String filePath,
  }) async {
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$senderId.jpg';

    final Reference storageRef = _storage
        .ref()
        .child('chat_media')
        .child(roomId)
        .child('photos')
        .child(fileName);

    await storageRef.putFile(File(filePath));

    final String downloadUrl = await storageRef.getDownloadURL();

    await messagesRef(roomId).push().set({
      "senderId": senderId,
      "type": "image",
      "imageUrl": downloadUrl,
      "timestamp": ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> messageStream(String roomId) {
    return messagesRef(roomId).onValue;
  }
}
