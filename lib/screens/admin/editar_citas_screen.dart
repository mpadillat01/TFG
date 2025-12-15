import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditCitaScreen extends StatefulWidget {
  final String citaId;
  const EditCitaScreen({required this.citaId, super.key});

  @override
  State<EditCitaScreen> createState() => _EditCitaScreenState();
}

class _EditCitaScreenState extends State<EditCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fechaController = TextEditingController();
  late final TextEditingController _horaController = TextEditingController();
  late final TextEditingController _estadoController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCitaData();
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _horaController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  Future<void> _loadCitaData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('citas')
          .doc(widget.citaId)
          .get();

      if (!doc.exists || doc.data() == null) {
        setState(() => _loading = false);
        return;
      }

      final data = doc.data()!;

      final Timestamp? timestamp = data['date'] as Timestamp?;
      _selectedDate = timestamp?.toDate();
      _fechaController.text = _selectedDate != null
          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
          : '';

      final dynamic rawTime = data['timeText'];
      if (rawTime != null && rawTime is String && rawTime.contains(':')) {
        final parts = rawTime.split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null && minute != null) {
            _selectedTime = TimeOfDay(hour: hour, minute: minute);
            _horaController.text = rawTime;
          }
        }
      }

      _estadoController.text = data['status']?.toString() ?? '';
    } catch (e) {
      debugPrint("Error cargando cita: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _horaController.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona fecha y hora válidas")),
      );
      return;
    }

    final fechaHora = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      await FirebaseFirestore.instance
          .collection('citas')
          .doc(widget.citaId)
          .update({
        'date': Timestamp.fromDate(fechaHora),
        'timeText':
            "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
        'status': _estadoController.text,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cita actualizada correctamente")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al actualizar: $e")));
    }
  }

  InputDecoration _inputDecoration(String label, {bool readOnly = false}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      suffixIcon: readOnly ? const Icon(Icons.calendar_today) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Editar Cita",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D6EFD),
        elevation: 4,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                shadowColor: Colors.black.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                      
                        TextFormField(
                          controller: _fechaController,
                          decoration: _inputDecoration("Fecha", readOnly: true),
                          readOnly: true,
                          onTap: _selectDate,
                          validator: (v) =>
                              v!.isEmpty ? "Campo obligatorio" : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _horaController,
                          decoration: _inputDecoration("Hora", readOnly: true),
                          readOnly: true,
                          onTap: _selectTime,
                          validator: (v) =>
                              v!.isEmpty ? "Campo obligatorio" : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _estadoController,
                          decoration: _inputDecoration("Estado"),
                          validator: (v) =>
                              v!.isEmpty ? "Campo obligatorio" : null,
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _guardarCambios,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D6EFD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 5,
                              shadowColor: Colors.black.withOpacity(0.2),
                            ),
                            child: Text(
                              "Guardar Cambios",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
