import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  final TextEditingController _motivoController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDoctor;

  final List<String> _doctores = [
    "Dr. Juan Martínez",
    "Dra. Ana Rodríguez",
    "Dr. Pedro Gómez",
  ];

  void _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _seleccionarHora() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _guardarCita() {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedDoctor == null ||
        _motivoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, completa todos los campos."),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      "nombre": "Tú mismo",
      "descripcion": _motivoController.text,
      "hora": _selectedTime!.format(context),
      "doctor": _selectedDoctor,
      "estado": "Pendiente",
      "fecha": _selectedDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva cita"),
        backgroundColor: const Color(0xFF0D6EFD),
      ),
      backgroundColor: const Color(0xFFF5F9FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Completa los datos de tu cita",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _seleccionarFecha,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? "Seleccionar fecha"
                          : DateFormat("EEEE, d 'de' MMMM", "es_ES")
                              .format(_selectedDate!),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0xFF0D6EFD)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _seleccionarHora,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedTime == null
                        ? "Seleccionar hora"
                        : _selectedTime!.format(context)),
                    const Icon(Icons.access_time, color: Color(0xFF0D6EFD)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedDoctor,
              items: _doctores
                  .map((doctor) => DropdownMenuItem(
                        value: doctor,
                        child: Text(doctor),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: "Selecciona el doctor",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _selectedDoctor = value),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _motivoController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Motivo de la cita o tratamiento",
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarCita,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Guardar cita"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
