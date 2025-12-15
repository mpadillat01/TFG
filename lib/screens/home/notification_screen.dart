import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajo_fin_grado/screens/home/notification_card.dart';
import 'package:trabajo_fin_grado/services/notification_services.dart'; 


class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  Future<void> _deleteNotification(String docId, String type) async {
    final collectionPath = type == 'recordatorio' ? 'notificaciones' : 'mensajes';
    
    if (type == 'admin') {
      await FirebaseFirestore.instance.collection('mensajes').doc(docId).delete();
      return;
    }

    await FirebaseFirestore.instance.collection(collectionPath).doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black, 
        body: Center(
          child: Text(
            'Inicia sesión para ver notificaciones',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600,
              color: Colors.white, 
            ),
          ),
        ),
      );
    }

    final notificationsStream = FirebaseFirestore.instance
        .collection('notificaciones')
        .where('clienteId', isEqualTo: user.uid)
        .snapshots();

    final adminMessagesStream = FirebaseFirestore.instance
        .collection('mensajes')
        .where('clienteId', isEqualTo: user.uid)
        .snapshots();

    final combinedStream = StreamZip([
      notificationsStream,
      adminMessagesStream,
    ]).map((lists) => [
          ...lists[0].docs, 
          ...lists[1].docs
        ]);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Notificaciones"),
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
          child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            stream: combinedStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              final docs = snapshot.data ?? [];

              if (docs.isEmpty) return const EmptyState();

              for (var d in docs) {
                final data = d.data();
                final fecha = (data['fecha_envio'] ?? data['fecha']) as Timestamp?;
                
                if (fecha != null) {
                  NotificationService.scheduleAppointmentReminder(
                    appointmentDate: fecha.toDate(),
                    doctor: data['doctor'] ?? 'Tu médico',
                  );
                }
              }

              return ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i];
                  final n = d.data();
                  final docId = d.id; 
                  final tipo = n['tipo'] ?? 'admin'; 
                  final fecha = (n['fecha_envio'] ?? n['fecha']) as Timestamp?;

                  return Dismissible(
                    key: Key(docId), 
                    direction: DismissDirection.endToStart, 
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white, size: 30),
                    ),
                    confirmDismiss: (direction) async {
                      return true; 
                    },
                    onDismissed: (direction) {
                      _deleteNotification(docId, tipo);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Notificación eliminada permanentemente."),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    },
                    child: NotificationCard(
                      title: n['titulo'] ??
                          (tipo == 'recordatorio'
                                  ? 'Recordatorio de cita'
                                  : 'Mensaje del admin'),
                      message: n['mensaje'] ?? '',
                      type: tipo,
                      date: fecha?.toDate(),
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
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

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
            "Aquí aparecerán avisos sobre tus citas y mensajes importantes del admin.",
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