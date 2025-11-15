import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../data/model/doctor_responsive.dart';
import '../../services/doctor_services.dart';
import '../../services/firestore_services.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  final _motivo = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  Doctor? _selectedDoctor;

  final fs = FirestoreService();

  List<Doctor> _doctores = [];
  List<String> _busyHours = [];
  bool _loadingDoctors = true;
  bool _loadingHours = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final doctors = await DoctorService().getDoctors();
    setState(() {
      _doctores = doctors;
      _loadingDoctors = false;
    });
  }

  Future<void> _loadBusyHours() async {
    if (_selectedDoctor == null || _date == null) return;

    setState(() => _loadingHours = true);

    _busyHours = await fs.getBusyHours(
      doctorId: _selectedDoctor!.id,
      date: _date!,
    );

    setState(() => _loadingHours = false);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );
    if (d != null) {
      setState(() => _date = d);
      await _loadBusyHours();
    }
  }

  Future<void> _pickTime() async {
    if (_selectedDoctor == null || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona doctor y fecha primero")),
      );
      return;
    }

    final now = DateTime.now();
    final isToday = _date!.day == now.day &&
        _date!.month == now.month &&
        _date!.year == now.year;

    final initialTime = isToday
        ? TimeOfDay(hour: now.hour, minute: now.minute)
        : const TimeOfDay(hour: 9, minute: 0);

    final t = await showTimePicker(context: context, initialTime: initialTime);
    if (t == null) return;

    final selectedHour = t.format(context);

    if (_busyHours.contains(selectedHour)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hora no disponible: $selectedHour")),
      );
      return;
    }

    if (isToday) {
      final selectedDateTime =
          DateTime(now.year, now.month, now.day, t.hour, t.minute);
      if (selectedDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No puedes seleccionar una hora pasada")),
        );
        return;
      }
    }

    setState(() => _time = t);
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_date == null || _time == null || _selectedDoctor == null || _motivo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos.')),
      );
      return;
    }

    final timeText = _time!.format(context);

    await fs.createAppointment(
      userId: user.uid,
      date: _date!,
      timeText: timeText,
      doctorId: _selectedDoctor!.id,
      doctorName: _selectedDoctor!.fullName,
      motivo: _motivo.text.trim(),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _date == null
        ? "Seleccionar fecha"
        : DateFormat("EEEE, d 'de' MMMM", "es_ES").format(_date!);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva cita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _Tile(label: dateText, icon: Icons.calendar_today, onTap: _pickDate),
            const SizedBox(height: 12),

            _Tile(
              label: _time == null ? "Seleccionar hora" : _time!.format(context),
              icon: Icons.access_time,
              onTap: _pickTime,
            ),
            const SizedBox(height: 12),

            _loadingDoctors
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<Doctor>(
                    value: _selectedDoctor,
                    items: _doctores.map((doc) {
                      return DropdownMenuItem(
                        value: doc,
                        child: Text(doc.fullName),
                      );
                    }).toList(),
                    onChanged: (v) async {
                      setState(() => _selectedDoctor = v);
                      await _loadBusyHours();
                    },
                    decoration: _fieldDeco("Selecciona el doctor"),
                  ),

            const SizedBox(height: 12),

            TextField(
              controller: _motivo,
              maxLines: 3,
              decoration: _fieldDeco("Motivo de la cita o tratamiento", alignWithHint: true),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Guardar cita'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDeco(String label, {bool alignWithHint = false}) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: alignWithHint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _Tile({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Icon(icon, color: const Color(0xFF0D6EFD))],
        ),
      ),
    );
  }
}
