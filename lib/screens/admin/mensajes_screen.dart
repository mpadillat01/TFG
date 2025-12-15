import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminMensajesScreen extends StatefulWidget {
  const AdminMensajesScreen({super.key});

  @override
  State<AdminMensajesScreen> createState() => _AdminMensajesScreenState();
}

class _AdminMensajesScreenState extends State<AdminMensajesScreen> {
  final _mensajeController = TextEditingController();
  String? _clienteSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Enviar Mensaje",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 24),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final usuarios = snapshot.data!.docs;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _clienteSeleccionado,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Selecciona un usuario",
                      ),
                      items: usuarios
                          .map((u) => DropdownMenuItem(
                                value: u.id,
                                child: Text(
                                  u['displayName'] ?? u['email'],
                                  style: GoogleFonts.poppins(),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _clienteSeleccionado = val),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _mensajeController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Escribe tu mensaje aquí...",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.3),
                    backgroundColor: const Color(0xFF0D6EFD),
                  ),
                  onPressed: () {
                    if (_clienteSeleccionado != null && _mensajeController.text.isNotEmpty) {
                      FirebaseFirestore.instance.collection('mensajes').add({
                        'clienteId': _clienteSeleccionado,
                        'mensaje': _mensajeController.text,
                        'fecha': DateTime.now(),
                      }).then((_) {
                        _mensajeController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Mensaje enviado")),
                        );
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Selecciona un usuario y escribe un mensaje")),
                      );
                    }
                  },
                  child: Text(
                    "Enviar",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
