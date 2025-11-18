import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trabajo_fin_grado/screens/home/market_screen.dart';
import 'package:trabajo_fin_grado/screens/home/new_appointments_screen.dart';

import '../../services/firestore_services.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();
  final fs = FirestoreService();

  Future<void> _abrirNuevaCita() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await Navigator.pushNamed(context, '/login');
      if (FirebaseAuth.instance.currentUser == null) return;
    }

    final ok = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewAppointmentScreen()),
    );

    if (ok == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final fecha = DateFormat("EEEE, d 'de' MMMM", "es_ES")
        .format(_selectedDate)
        .toUpperCase();

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text("Citas", style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MarketScreen()),
                );
              },
              icon: const Icon(Icons.storefront, size: 20, color: Color(0xFF0D6EFD)),
              label: const Text("Tienda",
                  style: TextStyle(color: Color(0xFF0D6EFD))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          )
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D6EFD), Color(0xFF4EA8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                Text(
                  "Consulta el calendario",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.85),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.25),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(.3),
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: _selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2026),
                        onDateChanged: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fecha,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _abrirNuevaCita,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF0D6EFD),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 6),
                          Text("Nueva cita",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: user == null
                      ? const Center(
                          child: Text(
                            "Inicia sesión para ver tus citas",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: fs.appointmentsByDate(userId: user.uid),
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }

                            // 🔥 FILTRAR AQUÍ POR FECHA (no en Firestore)
                            final citas = snap.data!.docs.where((d) {
                              final ts = d['date'] as Timestamp;
                              final fecha = ts.toDate();
                              return fecha.year == _selectedDate.year &&
                                  fecha.month == _selectedDate.month &&
                                  fecha.day == _selectedDate.day;
                            }).toList();

                            if (citas.isEmpty) {
                              return Center(
                                child: Text(
                                  "No hay citas este día",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.85),
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: citas.length,
                              itemBuilder: (_, i) {
                                final c = citas[i].data();
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.25),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(.35),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${c['doctorName']} • ${c['timeText']}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        c["motivo"] ?? "",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(.85),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
