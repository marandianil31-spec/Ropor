import 'package:firebase_database/firebase_database.dart';

class ChatService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

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
    "text": text,
    "timestamp": ServerValue.timestamp,
  });
}

Stream<DatabaseEvent> messageStream(String roomId) {
  return messagesRef(roomId).onValue;
}
}
