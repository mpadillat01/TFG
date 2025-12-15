import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CarritoScreen extends StatelessWidget {
  final Set<String>? carritoIds;
  const CarritoScreen({super.key, this.carritoIds});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Inicia sesión para ver el carrito")),
      );
    }

    final carritoRef = FirebaseFirestore.instance
        .collection("carrito")
        .doc(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text("Tu carrito")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: carritoRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          final productos = data?['productos'] as List<dynamic>? ?? [];

          if (productos.isEmpty) {
            return const Center(child: Text("Tu carrito está vacío"));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, i) {
                    final p = productos[i];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(p['cantidad'].toString()),
                      ),
                      title: Text(p['nombre']),
                      subtitle: Text("Precio: ${p['precio']} €"),
                      trailing: Text(
                        "${p['total']} €",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await registrarCompra(productos, user.uid);

                    await carritoRef.set({
                      'usuarioId': user.uid,
                      'fecha': Timestamp.now(),
                      'productos': [],
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Compra realizada con éxito"),
                      ),
                    );

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "COMPRAR",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> registrarCompra(List productos, String userId) async {
  final historialRef = FirebaseFirestore.instance.collection('historial');

  double total = 0;
  for (var p in productos) {
    total += (p['total'] as num).toDouble();
  }

  await historialRef.add({
    'usuarioId': userId,
    'fecha': Timestamp.now(),
    'productos': productos,
    'totalCompra': total,
  });
}