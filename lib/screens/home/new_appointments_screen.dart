import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/model/doctor_responsive.dart';
import '../../services/doctor_services.dart';
import '../../services/firestore_services.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen>
    with SingleTickerProviderStateMixin {

  final _motivo = TextEditingController();
  final fs = FirestoreService();

  DateTime? _date;
  TimeOfDay? _time;
  Doctor? _doctor;

  List<Doctor> _doctores = [];
  List<String> _busyHours = [];

  bool _loadingDoctors = true;
  bool _loadingHours = false;

  late AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _loadDoctors();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    final d = await DoctorService().getDoctors();
    setState(() {
      _doctores = d;
      _loadingDoctors = false;
    });
    _fade.forward();
  }

  Future<void> _loadBusyHours() async {
    if (_doctor == null || _date == null) return;
    setState(() => _loadingHours = true);

    _busyHours = await fs.getBusyHours(
      doctorId: _doctor!.id,
      date: _date!,
    );

    setState(() => _loadingHours = false);
  }

  Future<void> _pickDateWebSafe() async {
    DateTime now = DateTime.now();
    DateTime temp = _date ?? now;

    final selected = await showDialog<DateTime>(
      context: context,
      builder: (_) {
        return Center(
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.20),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(.4)),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                title: const Text(
                  "Selecciona una fecha",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                content: CalendarDatePicker(
                  initialDate: temp,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (d) => temp = d,
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancelar"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    child: const Text("Aceptar"),
                    onPressed: () => Navigator.pop(context, temp),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _date = selected);
      await _loadBusyHours();
    }
  }

  Future<void> _pickDate() async {
    if (kIsWeb) return _pickDateWebSafe();

    final picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _date = picked);
      await _loadBusyHours();
    }
  }

  Future<void> _pickTime() async {
    if (_doctor == null || _date == null) {
      return _msg("Selecciona primero el doctor y la fecha");
    }

    final now = DateTime.now();
    final isToday = _date!.difference(DateTime(now.year, now.month, now.day)).inDays == 0;

    final initial = isToday
        ? TimeOfDay(hour: now.hour, minute: now.minute)
        : const TimeOfDay(hour: 9, minute: 0);

    final t = await showTimePicker(context: context, initialTime: initial);
    if (t == null) return;

    final hourText = t.format(context);

    if (_busyHours.contains(hourText)) {
      return _msg("Hora no disponible: $hourText");
    }

    if (isToday) {
      final selected = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      if (selected.isBefore(now)) {
        return _msg("No puedes elegir una hora pasada");
      }
    }

    setState(() => _time = t);
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_date == null || _time == null || _doctor == null || _motivo.text.isEmpty) {
      return _msg("Completa todos los campos");
    }

    final timeText = _time!.format(context);

    await fs.createAppointment(
      userId: user.uid,
      date: _date!,
      timeText: timeText,
      doctorId: _doctor!.id,
      doctorName: _doctor!.fullName,
      motivo: _motivo.text.trim(),
    );

    Navigator.pop(context, true);
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t), backgroundColor: Colors.blue.shade600),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _date == null
        ? "Seleccionar fecha"
        : DateFormat("EEEE, d 'de' MMMM", "es_ES").format(_date!);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Nueva cita"),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FadeTransition(
                opacity: _fade,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [

                          _GlassTile(
                            label: dateLabel,
                            icon: Icons.calendar_today,
                            onTap: _pickDate,
                          ),

                          const SizedBox(height: 16),

                          _GlassTile(
                            label: _time == null ? "Seleccionar hora" : _time!.format(context),
                            icon: Icons.access_time,
                            onTap: _pickTime,
                          ),

                          const SizedBox(height: 16),

                          _glassCard(
                            child: _loadingDoctors
                                ? const Center(child: CircularProgressIndicator())
                                : DropdownButtonFormField<Doctor>(
                                    dropdownColor: Colors.white,
                                    value: _doctor,
                                    decoration: _input("Selecciona un doctor"),
                                    items: _doctores.map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e.fullName),
                                      ),
                                    ).toList(),
                                    onChanged: (v) async {
                                      setState(() => _doctor = v);
                                      await _loadBusyHours();
                                    },
                                  ),
                          ),

                          const SizedBox(height: 16),

                          _glassCard(
                            child: TextField(
                              controller: _motivo,
                              maxLines: 3,
                              decoration: _input("Motivo de la cita"),
                            ),
                          ),

                          const SizedBox(height: 35),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 6,
                              ),
                              onPressed: _save,
                              child: const Text(
                                "Confirmar cita",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.3)),
      ),
      child: child,
    );
  }

  InputDecoration _input(String t) => InputDecoration(
        labelText: t,
        labelStyle: const TextStyle(color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: Colors.white,
      );
}

class _GlassTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GlassTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.20),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
