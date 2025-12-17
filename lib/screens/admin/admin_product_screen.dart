import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trabajo_fin_grado/screens/admin/add_product_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final CollectionReference productosRef =
      FirebaseFirestore.instance.collection('productos');

  Future<void> _eliminarProducto(String id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text("¿Seguro que quieres eliminar '$nombre'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await productosRef.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto eliminado correctamente"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar producto: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _editarProducto(String id, Map<String, dynamic> data) async {
    final nombreController = TextEditingController(text: data['nombre']);
    final descripcionController = TextEditingController(text: data['descripcion']);
    final precioController = TextEditingController(text: data['precio'].toString());
    final stockController = TextEditingController(text: data['stock'].toString());
    final imagenController = TextEditingController(text: data['imagenUrl']);

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Editar Producto"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nombreController, decoration: const InputDecoration(labelText: "Nombre")),
                TextField(controller: descripcionController, decoration: const InputDecoration(labelText: "Descripción")),
                TextField(controller: precioController, decoration: const InputDecoration(labelText: "Precio"), keyboardType: TextInputType.number),
                TextField(controller: stockController, decoration: const InputDecoration(labelText: "Stock"), keyboardType: TextInputType.number),
                TextField(controller: imagenController, decoration: const InputDecoration(labelText: "URL Imagen")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                if (nombreController.text.isEmpty || descripcionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nombre y descripción no pueden estar vacíos"), backgroundColor: Colors.orange),
                  );
                  return;
                }

                try {
                  await productosRef.doc(id).update({
                    'nombre': nombreController.text,
                    'descripcion': descripcionController.text,
                    'precio': double.tryParse(precioController.text) ?? 0,
                    'stock': int.tryParse(stockController.text) ?? 0,
                    'imagenUrl': imagenController.text,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Producto actualizado correctamente"), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al actualizar producto: $e"), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: productosRef.orderBy('nombre').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No hay productos", style: TextStyle(fontSize: 18)));
        }

        final productos = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productos.length,
          itemBuilder: (context, i) {
            final doc = productos[i];
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: data['imagenUrl'] != null && data['imagenUrl'].isNotEmpty
                          ? Image.network(data['imagenUrl'], width: 80, height: 80, fit: BoxFit.cover)
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.production_quantity_limits_sharp, size: 40, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['nombre'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(data['descripcion'], style: TextStyle(color: Colors.grey.shade700)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                                child: Text("\$${data['precio']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
                                child: Text("Stock: ${data['stock']}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: "Editar producto",
                          onPressed: () => _editarProducto(doc.id, data),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "Eliminar producto",
                          onPressed: () => _eliminarProducto(doc.id, data['nombre']),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
