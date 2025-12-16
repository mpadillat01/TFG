import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabajo_fin_grado/screens/home/card/product_card.dart';
import 'package:trabajo_fin_grado/widgets/widget_pantallas/cart_widget.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  Set<String> _carrito = {};

  @override
  void initState() {
    super.initState();
    _loadCarrito();
  }

  Future<void> _loadCarrito() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('carrito')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final productos = List<Map<String, dynamic>>.from(doc['productos'] ?? []);
      setState(() {
        _carrito = productos.map((p) => p['productoId'] as String).toSet();
      });
    }
  }

  Future<void> _toggleCarrito(String id, String nombre, double precio) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Inicia sesión"),
          content: const Text(
            "Debes iniciar sesión para añadir productos al carrito.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        ),
      );
      return;
    }

    final carritoRef = FirebaseFirestore.instance
        .collection("carrito")
        .doc(user.uid);
    final doc = await carritoRef.get();

    List<Map<String, dynamic>> productos = [];
    if (doc.exists) {
      productos = List<Map<String, dynamic>>.from(doc['productos'] ?? []);
    }

    final index = productos.indexWhere((p) => p['productoId'] == id);

    if (index >= 0) {
      productos.removeAt(index);
      setState(() => _carrito.remove(id));
    } else {
      productos.add({
        'productoId': id,
        'nombre': nombre,
        'precio': precio,
        'cantidad': 1,
        'total': precio,
      });
      setState(() => _carrito.add(id));
    }

    await carritoRef.set({
      'usuarioId': user.uid,
      'fecha': Timestamp.now(),
      'productos': productos,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Tienda",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [CartWidget(carritoCount: _carrito.length, carrito: _carrito)],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D6EFD), Color(0xFF4EA8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('productos')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No hay productos",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              final productos = snapshot.data!.docs;
              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth < 600
                      ? 2
                      : constraints.maxWidth < 900
                      ? 3
                      : 4;
                  double childAspectRatio = constraints.maxWidth < 600
                      ? 0.65
                      : constraints.maxWidth < 900
                      ? 0.7
                      : 0.75;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: productos.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, i) {
                      final doc = productos[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final id = doc.id;
                      final enCarrito = _carrito.contains(id);

                      return ProductoCard(
                        id: id,
                        nombre: data['nombre'],
                        descripcion: data['descripcion'],
                        precio: (data['precio'] as num).toDouble(),
                        imagenUrl: data['imagenUrl'],
                        enCarrito: enCarrito,
                        onAdd: () => _toggleCarrito(
                          id,
                          data['nombre'],
                          (data['precio'] as num).toDouble(),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}



