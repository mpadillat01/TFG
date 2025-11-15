import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabajo_fin_grado/screens/home/market_screen.dart';
import 'package:trabajo_fin_grado/screens/home/new_appointments_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() => _isLoggedIn = user != null);
    });
  }

  void _abrirNuevaCita() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await Navigator.pushNamed(context, '/login');
      if (FirebaseAuth.instance.currentUser == null) return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewAppointmentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Citas"),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketScreen()),
              );
            },
            icon: const Icon(Icons.storefront, color: Colors.white),
            label: const Text(
              "Tienda",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Consulta el calendario",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2026),
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat("EEEE, d 'de' MMMM", "es_ES")
                      .format(_selectedDate)
                      .toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: _abrirNuevaCita,
                  icon: const Icon(Icons.add),
                  label: const Text("Nueva cita"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Center(
                child: Text(
                  "Selecciona una fecha y pulsa \"Nueva cita\"",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
