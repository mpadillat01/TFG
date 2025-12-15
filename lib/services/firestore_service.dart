import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> fetchUserName(String userId) async {
    if (userId.isEmpty) {
      return 'Cliente Desconocido (ID no válido)';
    }
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['name'] ??
            userData['displayName'] ??
            'Cliente Desconocido (ID: $userId)';
      }
      return 'Cliente Desconocido (ID no encontrado)';
    } catch (e) {
      print("Error al obtener el nombre del cliente: $e");
      return 'Error al cargar el cliente';
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
        .get();

    final busyHours = query.docs
        .map((d) => d.data())
        .where((d) {
          final ts = d['date'] as Timestamp;
          final dt = ts.toDate();
          return dt.isAfter(start.subtract(const Duration(seconds: 1))) &&
              dt.isBefore(end);
        })
        .map((d) => d['timeText'] as String)
        .toList();

    return busyHours;
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

  Stream<QuerySnapshot<Map<String, dynamic>>> appointmentsAll() {
    return _db.collection('citas').snapshots();
  }
}
