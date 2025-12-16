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
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.blueGrey.shade700,
      ),
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
            colors: [Colors.blue.shade700, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 14,
                  shadowColor: Colors.blueAccent.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag,
                                color: Colors.blue.shade700,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Nuevo producto",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Text(
                            "Completa la información del producto",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.blueGrey.shade500,
                            ),
                          ),

                          const SizedBox(height: 28),

                          TextFormField(
                            controller: _nombreController,
                            decoration: _inputDecoration(
                              "Nombre",
                            ).copyWith(prefixIcon: const Icon(Icons.label)),
                            validator: (v) => v!.isEmpty ? "Obligatorio" : null,
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _categoriaController,
                            decoration: _inputDecoration(
                              "Categoría",
                            ).copyWith(prefixIcon: const Icon(Icons.category)),
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _descripcionController,
                            maxLines: 3,
                            decoration: _inputDecoration("Descripción")
                                .copyWith(
                                  prefixIcon: const Icon(Icons.description),
                                ),
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _imagenUrlController,
                            decoration: _inputDecoration(
                              "URL de imagen",
                            ).copyWith(prefixIcon: const Icon(Icons.image)),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _precioController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration("Precio (€)")
                                      .copyWith(
                                        prefixIcon: const Icon(
                                          Icons.euro_rounded,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextFormField(
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration("Stock")
                                      .copyWith(
                                        prefixIcon: const Icon(
                                          Icons.inventory_2,
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _guardarProducto,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                elevation: 10,
                                shadowColor: Colors.blueAccent.withOpacity(
                                  0.45,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: Text(
                                "Guardar producto",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                  color: Colors.white,
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
            ),
          ),
        ),
      ),
    );
  }
}
