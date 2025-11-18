import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajo_fin_grado/services/firestore_services.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Inicia sesión para ver notificaciones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    final fs = FirestoreService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Notificaciones"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D6EFD), Color(0xFF4EA8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: fs.notifications(user.uid),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final docs = snap.data?.docs ?? [];

              if (docs.isEmpty) return const _Empty();

              return ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final n = docs[i].data();

                  return _NotificationCard(
                    title: n["titulo"] ?? "Notificación",
                    message: n["mensaje"] ?? "",
                    type: n["tipo"] ?? "general",
                    date: (n["fecha_envio"] as Timestamp?)?.toDate(), // ✅ CAMBIO CRÍTICO
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String type;
  final DateTime? date;

  const _NotificationCard({
    required this.title,
    required this.message,
    required this.type,
    this.date,
  });

  IconData _getIcon() {
    switch (type) {
      case "cita":
        return Icons.event_available;
      case "recordatorio":
        return Icons.notifications_active;
      case "admin":
        return Icons.verified_user_rounded;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor() {
    switch (type) {
      case "cita":
        return Colors.greenAccent.shade400;
      case "recordatorio":
        return Colors.yellowAccent.shade400;
      case "admin":
        return Colors.redAccent.shade400;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_getIcon(), color: color, size: 28),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.85),
                    fontSize: 14,
                  ),
                ),

                if (date != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "${date!.day}/${date!.month}/${date!.year} "
                    "• ${date!.hour.toString().padLeft(2, '0')}:"
                    "${date!.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
          Icon(Icons.notifications_none,
              size: 120, color: Colors.white.withOpacity(.55)),
          const SizedBox(height: 16),
          const Text(
            "No tienes notificaciones",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Aquí aparecerán avisos sobre citas,\nrecordatorios y mensajes.",
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
