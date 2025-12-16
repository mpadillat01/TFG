import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trabajo_fin_grado/screens/admin/editar_citas_screen.dart';
import 'package:trabajo_fin_grado/services/firestore_service.dart';

class AdminCitasScreen extends StatefulWidget {
  const AdminCitasScreen({super.key});

  @override
  State<AdminCitasScreen> createState() => _AdminCitasScreenState();
}

class _AdminCitasScreenState extends State<AdminCitasScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(value.toDate());
    }
    return value.toString();
  }

  Future<void> _actualizarCitasPasadas(
    String citaId,
    Timestamp fechaCita,
    String estadoActual,
  ) async {
    final DateTime hoy = DateTime.now();
    final DateTime fecha = fechaCita.toDate();

    final DateTime hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
    final DateTime fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);

    if (fechaSinHora.isBefore(hoySinHora) &&
        estadoActual.toLowerCase() == 'pendiente') {
      await FirebaseFirestore.instance.collection('citas').doc(citaId).update({
        'status': 'completada',
      });
    }
  }

  Future<void> _deleteCita(String citaId) async {
    try {
      await FirebaseFirestore.instance.collection('citas').doc(citaId).delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita eliminada correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar la cita: $e')));
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String citaId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta cita? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCita(citaId);
            },
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
        return Colors.green.shade700;
      case 'cancelada':
        return Colors.red;
      case 'completada':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.appointmentsAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay citas registradas."));
          }

          final citas = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            itemCount: citas.length,
            itemBuilder: (context, i) {
              final citaDoc = citas[i];
              final Map<String, dynamic> cita = citaDoc.data();

              final String userId = cita['userId'] ?? '';
              final String doctorName =
                  cita['doctorName'] ?? 'Doctor Desconocido';
              final String fechaDisplay = _formatDate(
                cita['date'] ?? 'Fecha no definida',
              );
              final String hora = cita['timeText'] ?? 'Hora no definida';
              final String estado = cita['status'] ?? 'pendiente';
              final String motivo = cita['motivo'] ?? 'Motivo no definido';

              final Timestamp? fechaTimestamp = cita['date'];

              if (fechaTimestamp != null) {
                _actualizarCitasPasadas(citaDoc.id, fechaTimestamp, estado);
              }

              return FutureBuilder<String>(
                future: _firestoreService.fetchUserName(userId),
                builder: (context, nameSnapshot) {
                  final String clienteNombre;
                  if (nameSnapshot.connectionState == ConnectionState.waiting) {
                    clienteNombre = 'Cargando cliente...';
                  } else if (nameSnapshot.hasError || !nameSnapshot.hasData) {
                    clienteNombre = 'Error al cargar el cliente';
                  } else {
                    clienteNombre = nameSnapshot.data!;
                  }

                  return Card(
                    elevation: 8,
                    shadowColor: Colors.blueAccent.withOpacity(0.18),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.blue.shade50.withOpacity(0.35),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        clienteNombre,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blueGrey.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Dr/a. $doctorName",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.blueGrey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getEstadoColor(
                                      estado,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    estado.toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _getEstadoColor(estado),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Divider(height: 1),

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  fechaDisplay,
                                  style: GoogleFonts.poppins(
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  hora,
                                  style: GoogleFonts.poppins(
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.notes,
                                  size: 18,
                                  color: Colors.blueGrey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    motivo,
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  tooltip: "Editar cita",
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blueGrey,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditCitaScreen(citaId: citaDoc.id),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  tooltip: "Eliminar cita",
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _showDeleteConfirmationDialog(
                                        context,
                                        citaDoc.id,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
