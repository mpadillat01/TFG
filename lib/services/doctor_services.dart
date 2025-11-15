import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabajo_fin_grado/data/model/doctor_responsive.dart';

class DoctorService {
  final _db = FirebaseFirestore.instance;

  Future<List<Doctor>> getDoctors() async {
    final snapshot = await _db.collection('doctor').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Doctor(
        doc.id,
        data['nombre'] ?? '',
        data['apellidos'] ?? '',
      );
    }).toList();
  }
}
