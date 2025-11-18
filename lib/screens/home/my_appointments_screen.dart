import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_services.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const _NeedLogin();

    final fs = FirestoreService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Mis Citas"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: fs.myAppointments(user.uid),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final docs = snap.data!.docs;

              if (docs.isEmpty) return const _Empty();

              docs.sort((a, b) {
                final da = a['date'] as Timestamp?;
                final db = b['date'] as Timestamp?;
                return (db ?? Timestamp.now()).compareTo(da ?? Timestamp.now());
              });

              return ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i].data();
                  final fecha = (d['date'] as Timestamp?)?.toDate();
                  final status = (d['status'] ?? 'pendiente').toString();
                  final color = _statusColor(status);

                  return _GlassCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(.20),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.calendar_month,
                            color: color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${d['doctorName']} • ${d['timeText']}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (fecha != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "${fecha.day}/${fecha.month}/${fecha.year}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.85),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Text(
                                d['motivo'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.75),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(.25),
                            border: Border.all(color: color.withOpacity(.45)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
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
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "pendiente":
        return Colors.yellowAccent.shade400;
      case "confirmada":
        return Colors.greenAccent.shade400;
      case "cancelada":
        return Colors.redAccent.shade400;
      default:
        return Colors.white;
    }
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.35)),
      ),
      child: child,
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 120,
            color: Colors.white.withOpacity(.55),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aún no tienes citas",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Cuando reserves alguna cita,\naparecerá aquí.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(.85),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeedLogin extends StatelessWidget {
  const _NeedLogin();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Inicia sesión para ver tus citas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
