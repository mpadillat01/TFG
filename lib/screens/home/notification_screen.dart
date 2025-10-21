import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      "titulo": "Recordatorio de cita",
      "mensaje": "Tienes una cita pendiente el 25 de octubre a las 09:30.",
      "fecha": DateTime(2025, 10, 18),
    },
    {
      "titulo": "Promoción en productos",
      "mensaje": "Aprovecha un 20% de descuento en cremas hidratantes.",
      "fecha": DateTime(2025, 10, 15),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text("Notificaciones"),
        backgroundColor: const Color(0xFF0D6EFD),
        centerTitle: true,
        elevation: 0,
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text(
                "No tienes notificaciones nuevas",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, i) {
                final notif = _notifications[i];
                final fecha = DateFormat("d MMM yyyy", "es_ES")
                    .format(notif["fecha"] as DateTime);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D6EFD),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      notif["titulo"],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notif["mensaje"],
                        style: const TextStyle(color: Colors.black54, height: 1.4),
                      ),
                    ),
                    trailing: Text(
                      fecha,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black38,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
