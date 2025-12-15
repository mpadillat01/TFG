import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddProductoScreen extends StatefulWidget {
  const AddProductoScreen({super.key});

  @override
  State<AddProductoScreen> createState() => _AddProductoScreenState();
}

class _AddProductoScreenState extends State<AddProductoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _categoriaController;
  late TextEditingController _descripcionController;
  late TextEditingController _imagenUrlController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _categoriaController = TextEditingController();
    _descripcionController = TextEditingController();
    _imagenUrlController = TextEditingController();
    _precioController = TextEditingController(text: "0");
    _stockController = TextEditingController(text: "1");
  }

  void _guardarProducto() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('productos').add({
        "nombre": _nombreController.text,
        "categoria": _categoriaController.text,
        "descripcion": _descripcionController.text,
        "imagenUrl": _imagenUrlController.text,
        "precio": double.tryParse(_precioController.text) ?? 0,
        "stock": int.tryParse(_stockController.text) ?? 1,
        "fechaCreacion": Timestamp.now(),
      });

      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.blueGrey.shade700),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Text(
                        "Añadir Nuevo Producto",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: _nombreController,
                        decoration: _inputDecoration("Nombre"),
                        validator: (v) => v!.isEmpty ? "Obligatorio" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _categoriaController,
                        decoration: _inputDecoration("Categoría"),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: _inputDecoration("Descripción"),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _imagenUrlController,
                        decoration: _inputDecoration("URL de Imagen"),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _precioController,
                              decoration: _inputDecoration("Precio (€)"),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              decoration: _inputDecoration("Stock"),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _guardarProducto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: Text(
                            "Guardar Producto",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
