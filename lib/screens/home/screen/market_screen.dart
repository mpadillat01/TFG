import 'dart:ui';

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
  Set<String> _carritoIds = {};

  @override
  void initState() {
    super.initState();
    _loadCarrito();
  }

  Future<void> _loadCarrito() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('carrito')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists && mounted) {
        final productos = List<Map<String, dynamic>>.from(doc['productos'] ?? []);
        setState(() {
          _carritoIds = productos.map((p) => p['productoId'] as String).toSet();
        });
      }
    });
  }

  Future<void> _addToCart(String id, String nombre, double precio, int stock) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { _showLoginDialog(); return; }

    final carritoRef = FirebaseFirestore.instance.collection("carrito").doc(user.uid);
    final doc = await carritoRef.get();

    List<Map<String, dynamic>> productosEnCarrito = doc.exists 
        ? List<Map<String, dynamic>>.from(doc['productos'] ?? []) 
        : [];

    final index = productosEnCarrito.indexWhere((p) => p['productoId'] == id);
    int cantidadYaEnCarrito = index >= 0 ? productosEnCarrito[index]['cantidad'] : 0;
    int stockRealDisponible = stock - cantidadYaEnCarrito;

    if (stockRealDisponible <= 0) {
      _showCustomSnackBar("¡Stock agotado para este artículo!");
      return;
    }

    int? cantidad = await _mostrarDialogoCantidad(nombre, stockRealDisponible);
    if (cantidad == null) return;

    if (index >= 0) {
      productosEnCarrito[index]['cantidad'] += cantidad;
      productosEnCarrito[index]['total'] = productosEnCarrito[index]['precio'] * productosEnCarrito[index]['cantidad'];
    } else {
      productosEnCarrito.add({
        'productoId': id, 'nombre': nombre, 'precio': precio, 'cantidad': cantidad, 'total': precio * cantidad,
      });
    }

    await carritoRef.set({'usuarioId': user.uid, 'fecha': Timestamp.now(), 'productos': productosEnCarrito});
    _showCustomSnackBar("Añadido al carrito con éxito", isError: false);
  }

  void _showCustomSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.redAccent : Colors.greenAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D6EFD), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  expandedHeight: 80,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  centerTitle: true,
                  title: const Text(
                    "Marketplace",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 1.2),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: CartWidget(carritoCount: _carritoIds.length, carrito: _carritoIds),
                    ),
                  ],
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  sliver: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('productos').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.white)));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const SliverFillRemaining(child: _EmptyCart());
                      }

                      final productos = snapshot.data!.docs;
                      
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _calculateColumns(context),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final data = productos[i].data() as Map<String, dynamic>;
                            final id = productos[i].id;
                            final stock = data['stock'] ?? 0;

                            return Hero(
                              tag: 'prod_$id',
                              child: ProductoCard(
                                id: id,
                                nombre: data['nombre'] ?? '',
                                descripcion: data['descripcion'] ?? '',
                                precio: (data['precio'] as num).toDouble(),
                                imagenUrl: data['imagenUrl'] ?? '',
                                enCarrito: _carritoIds.contains(id),
                                agotado: stock <= 0,
                                onAdd: () => _addToCart(id, data['nombre'], (data['precio'] as num).toDouble(), stock),
                              ),
                            );
                          },
                          childCount: productos.length,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateColumns(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  void _showLoginDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              title: const Text("¡Hola! 👋", style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text("Necesitas una cuenta para empezar a llenar tu carrito."),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vale, entiendo")),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<int?> _mostrarDialogoCantidad(String nombre, int stock) {
    int localCant = 1;
    return showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text("¿Cuántos te llevas?", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(nombre, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(onPressed: () => setDialogState(() { if (localCant > 1) localCant--; }), icon: const Icon(Icons.remove)),
                    Text("$localCant", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => setDialogState(() { if (localCant < stock) localCant++; }), icon: const Icon(Icons.add)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text("Quedan $stock disponibles", style: const TextStyle(color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D6EFD), shape: StadiumBorder()),
              onPressed: () => Navigator.pop(context, localCant), 
              child: const Text("¡Añadir!", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.white.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text("La tienda está vacía...", style: TextStyle(color: Colors.white70, fontSize: 18)),
        ],
      ),
    );
  }
}