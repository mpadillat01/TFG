import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trabajo_fin_grado/screens/auth/login_screen.dart';
import 'package:trabajo_fin_grado/screens/home/screen/new_appointments_screen.dart';

import '../../../services/firestore_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();
  final fs = FirestoreService();

  final List<DateTime> _spanishHolidays = [
    DateTime(2025, 1, 1),
    DateTime(2025, 1, 6),
    DateTime(2025, 2, 16),
    DateTime(2025, 4, 17),
    DateTime(2025, 4, 18),
    DateTime(2025, 5, 1),
    DateTime(2025, 8, 15),
    DateTime(2025, 10, 12),
    DateTime(2025, 11, 1),
    DateTime(2025, 12, 6),
    DateTime(2025, 12, 8),
    DateTime(2025, 12, 25),
    DateTime(2026, 1, 1),
    DateTime(2026, 1, 6),
    DateTime(2026, 2, 17),
    DateTime(2026, 4, 2),
    DateTime(2026, 4, 3),
    DateTime(2026, 5, 1),
    DateTime(2026, 8, 15),
    DateTime(2026, 9, 8),
    DateTime(2026, 10, 12),
    DateTime(2026, 11, 1),
    DateTime(2026, 11, 2),
    DateTime(2026, 12, 6),
    DateTime(2026, 12, 7),
    DateTime(2026, 12, 8),
    DateTime(2026, 12, 25),
  ];

  DateTime _normalize(DateTime d) {
    final local = d.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  bool _isHoliday(DateTime day) {
    final d = _normalize(day);
    return _spanishHolidays.any((h) => _normalize(h).isAtSameMomentAs(d));
  }

  Future<void> _abrirNuevaCita() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (ok != true) return;
    }

    final ok = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewAppointmentScreen()),
    );

    if (ok == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat(
      "EEEE, d 'de' MMMM",
      "es_ES",
    ).format(_selectedDate);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A4FF5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Mis Citas",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A4FF5), Color(0xFF50A9FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        "Calendario de consultas",
                        style: TextStyle(
                          color: Colors.white.withOpacity(.97),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildModernCalendar(),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fecha.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: .7,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _abrirNuevaCita,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0A4FF5),
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 22),
                            label: const Text(
                              "Nueva cita",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildListaCitas(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernCalendar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(.15),
            border: Border.all(color: Colors.white.withOpacity(.35)),
          ),
          child: CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime(2023),
            lastDate: DateTime(2028),
            selectableDayPredicate: (day) {
              final d = _normalize(day);
              if (d.weekday == DateTime.sunday) return false;
              if (_isHoliday(d)) return false;
              return true;
            },
            onDateChanged: (d) => setState(() => _selectedDate = _normalize(d)),
          ),
        ),
      ),
    );
  }

  Widget _buildListaCitas() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;
        final stream = user == null
            ? fs.appointmentsAll()
            : fs.appointmentsByDate(userId: user.uid);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (_, s) {
            if (s.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (!s.hasData) {
              return const Center(
                child: Text("No se pudieron cargar las citas"),
              );
            }

            final citas = s.data!.docs.where((d) {
              final fecha = (d['date'] as Timestamp).toDate();
              final f = _normalize(fecha);
              return f.year == _selectedDate.year &&
                  f.month == _selectedDate.month &&
                  f.day == _selectedDate.day;
            }).toList();

            if (citas.isEmpty) {
              return Center(
                child: Text(
                  "No hay citas este día",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.95),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 6, bottom: 16),
              itemCount: citas.length,
              itemBuilder: (_, i) => _buildCita(citas[i].id, citas[i].data()),
            );
          },
        );
      },
    );
  }

  Widget _buildCita(String citaId, Map<String, dynamic> c) {
    final user = FirebaseAuth.instance.currentUser;
    final esPropia = user != null && c['userId'] == user.uid;
    final fechaCita = (c['date'] as Timestamp).toDate();

    final partesHora = c['timeText'].split(':');
    final hora = int.parse(partesHora[0]);
    final minuto = int.parse(partesHora[1]);

    final fechaHoraCita = DateTime(
      fechaCita.year,
      fechaCita.month,
      fechaCita.day,
      hora,
      minuto,
    );

    final citaPasada = fechaHoraCita.isBefore(DateTime.now());

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.22),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(.35)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 25,
                child: Icon(
                  Icons.medical_services_rounded,
                  color: Color(0xFF0A4FF5),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${c['doctorName']} • ${c['timeText']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c["motivo"] ?? "",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.90),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (esPropia && !citaPasada)
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  onPressed: () => _confirmarCancelacion(citaId),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarCancelacion(String citaId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancelar cita"),
        content: const Text(
          "¿Seguro que quieres cancelar esta cita?\n\n"
          "La hora quedará disponible para otros usuarios.",
        ),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Sí, cancelar"),
            onPressed: () async {
              Navigator.pop(context);
              await fs.borrarCita(citaId);
            },
          ),
        ],
      ),
    );
  }
}
