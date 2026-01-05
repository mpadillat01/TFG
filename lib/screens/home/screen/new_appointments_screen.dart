import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trabajo_fin_grado/data/model/doctor_responsive.dart';
import 'package:trabajo_fin_grado/services/doctor_services.dart';
import 'package:trabajo_fin_grado/services/firestore_service.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  final _motivo = TextEditingController();
  final fs = FirestoreService();

  DateTime? _date;
  TimeOfDay? _time;
  Doctor? _doctor;

  List<Doctor> _doctores = [];
  List<String> _busyHours = [];
  bool _loadingDoctors = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    final d = await DoctorService().getDoctors();
    setState(() {
      _doctores = d;
      _loadingDoctors = false;
    });
  }

  Future<void> _loadBusyHours() async {
    if (_doctor == null || _date == null) return;
    _busyHours = await fs.getBusyHours(doctorId: _doctor!.id, date: _date!);
  }

  DateTime _normalize(DateTime d) {
    final local = d.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  bool _isHoliday(DateTime day) {
    final d = _normalize(day);
    final year = d.year;

    final fixedHolidays = [
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

    final easter = _calculateEaster(year);
    final easterThursday = easter.subtract(const Duration(days: 3));
    final goodFriday = easter.subtract(const Duration(days: 2));

    final dynamicHolidays = [easterThursday, goodFriday];

    return [...fixedHolidays, ...dynamicHolidays]
        .any((h) => _normalize(h).isAtSameMomentAs(d));
  }

  DateTime _calculateEaster(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (day) {
        final d = _normalize(day);
        if (d.weekday == DateTime.sunday) return false;
        if (_isHoliday(d)) return false;
        return true;
      },
    );

    if (picked != null) {
      setState(() {
        _date = _normalize(picked);
        _time = null;
      });
      await _loadBusyHours();
    }
  }

  Future<void> _pickTime() async {
    if (_doctor == null || _date == null) return _msg("Selecciona primero el doctor y la fecha");

    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(_date, now);
    final isSaturday = _date!.weekday == DateTime.saturday;

    List<TimeOfDay> generateRange(int h1, int m1, int h2, int m2) {
      final list = <TimeOfDay>[];
      var t = DateTime(0, 0, 0, h1, m1);
      final end = DateTime(0, 0, 0, h2, m2);
      while (!t.isAfter(end)) {
        list.add(TimeOfDay(hour: t.hour, minute: t.minute));
        t = t.add(const Duration(minutes: 30));
      }
      return list;
    }

    final morning = generateRange(9, 0, 14, 0);
    final afternoon = isSaturday ? <TimeOfDay>[] : generateRange(16, 0, 21, 30);

    final selected = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        Widget buildGrid(List<TimeOfDay> times) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: times.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.6,
            ),
            itemBuilder: (_, i) {
              final t = times[i];
              final text = t.format(context);
              final isPast = isToday && (t.hour < now.hour || (t.hour == now.hour && t.minute <= now.minute));
              final isBusy = _busyHours.contains(text);
              final disabled = isPast || isBusy;

              return ElevatedButton(
                onPressed: disabled ? null : () => Navigator.pop(context, t),
                style: ElevatedButton.styleFrom(
                  backgroundColor: disabled ? Colors.grey.shade300 : Colors.blue,
                  foregroundColor: disabled ? Colors.grey.shade600 : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(text),
              );
            },
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Mañana", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              buildGrid(morning),
              if (afternoon.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text("Tarde", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                buildGrid(afternoon),
              ],
            ],
          ),
        );
      },
    );

    if (selected != null) setState(() => _time = selected);
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_date == null || _time == null || _doctor == null || _motivo.text.isEmpty) {
      return _msg("Completa todos los campos");
    }
    await fs.createAppointment(
      userId: user.uid,
      date: _date!,
      timeText: _time!.format(context),
      doctorId: _doctor!.id,
      doctorName: _doctor!.fullName,
      motivo: _motivo.text.trim(),
    );
    Navigator.pop(context, true);
  }

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    final dateLabel = _date == null
        ? "Seleccionar fecha"
        : DateFormat("EEEE, d 'de' MMMM", "es_ES").format(_date!);

    return Scaffold(
      appBar: AppBar(title: const Text("Nueva cita"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _ModernTile(label: dateLabel, icon: Icons.calendar_month, onTap: _pickDate),
            const SizedBox(height: 16),
            _ModernTile(label: _time?.format(context) ?? "Seleccionar hora", icon: Icons.access_time, onTap: _pickTime),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<Doctor>(
                  isExpanded: true,
                  value: _doctor,
                  decoration: const InputDecoration(labelText: "Doctor", border: OutlineInputBorder()),
                  items: _doctores.map((d) => DropdownMenuItem(value: d, child: Text(d.fullName, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) async { setState(() => _doctor = v); await _loadBusyHours(); },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _motivo, maxLines: 3, decoration: const InputDecoration(labelText: "Motivo de la consulta", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(onPressed: _save, child: const Text("Confirmar cita")),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ModernTile({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Colors.blue.shade100, child: Icon(icon, color: Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: Text(label)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
