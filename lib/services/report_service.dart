import 'package:firebase_database/firebase_database.dart';

class ReportService {
  static final DatabaseReference _reportsRef =
      FirebaseDatabase.instance.ref().child('reports');

  static Future<void> submitReport({
    required String reporterId,
    required String roomId,
    required String reason,
  }) async {
    final newReport = _reportsRef.push();

    await newReport.set({
      'reporterId': reporterId,
      'roomId': roomId,
      'reason': reason,
      'createdAt': ServerValue.timestamp,
    });
  }
}
