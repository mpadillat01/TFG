import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> fetchUserName(String userId) async {
    if (userId.isEmpty) return 'Cliente Desconocido';

    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) return 'Cliente Desconocido';

      final data = doc.data()!;
      return data['name'] ??
          data['displayName'] ??
          'Cliente Desconocido';
    } catch (e) {
      return 'Error al cargar cliente';
    }
  }

  Future<void> createAppointment({
    required String userId,
    required DateTime date,
    required String timeText,
    required String doctorId,
    required String doctorName,
    required String motivo,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _db
        .collection('citas')
        .where('doctorId', isEqualTo: doctorId)
        .where('timeText', isEqualTo: timeText)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(end),
        )
        .get();

    final ocupada = snap.docs.any((d) =>
        d['status'] == 'pendiente' || d['status'] == 'activa');

    if (ocupada) {
      throw Exception('Esa hora ya está ocupada');
    }

    await _db.collection('citas').add({
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': Timestamp.fromDate(date),
      'timeText': timeText,
      'motivo': motivo,
      'status': 'pendiente',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getBusyHours({
    required String doctorId,
    required DateTime date,
  }) async {
    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      final snap = await _db
          .collection('citas')
          .where('doctorId', isEqualTo: doctorId)
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where(
            'date',
            isLessThan: Timestamp.fromDate(end),
          )
          .get();

      return snap.docs
          .where((d) =>
              d['status'] == 'pendiente' || d['status'] == 'activa')
          .map((d) => d['timeText'] as String)
          .toSet()
          .toList();
    } catch (e) {
      return [];
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myAppointments(String userId) {
    return _db
        .collection('citas')
        .where('userId', isEqualTo: userId)
        .orderBy('date')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> appointmentsAll() {
    return _db
        .collection('citas')
        .orderBy('date')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> appointmentsByDate({
    required String userId,
  }) {
    return _db
        .collection('citas')
        .where('userId', isEqualTo: userId)
        .orderBy('date')
        .snapshots();
  }

  Future<void> cancelarCita(String citaId) async {
    await _db.collection('citas').doc(citaId).update({
      'status': 'cancelada',
    });
  }

  Future<void> borrarCita(String citaId) async {
    await _db.collection('citas').doc(citaId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> notifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }
}
