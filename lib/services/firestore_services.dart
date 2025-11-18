import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createAppointment({
    required String userId,
    required DateTime date,
    required String timeText,
    required String doctorId,
    required String doctorName,
    required String motivo,
  }) async {
    await _db.collection('citas').add({
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'timeText': timeText,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'motivo': motivo,
      'status': 'pendiente',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myAppointments(String userId) {
  return _db
      .collection('citas')
      .where('userId', isEqualTo: userId)
      .snapshots();
}

  Future<List<String>> getBusyHours({
    required String doctorId,
    required DateTime date,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final query = await _db
        .collection('citas')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    return query.docs.map((d) => d['timeText'] as String).toList();
  }


  Stream<QuerySnapshot<Map<String, dynamic>>> notifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

Stream<QuerySnapshot<Map<String, dynamic>>> appointmentsByDate({
  required String userId,
}) {
  return _db
      .collection('citas')
      .where('userId', isEqualTo: userId)
      .snapshots();
}


}
