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

  Future<void> _addToCart(String id, String nombre, double precio, int stock) async {
    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto agotado"), backgroundColor: Colors.red),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Inicia sesión"),
          content: const Text("Debes iniciar sesión para añadir productos al carrito."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
          ],
        ),
      );
      return;
    }

    int cantidad = 1;

    final result = await showDialog<int>(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Cantidad de $nombre"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (cantidad > 1) setState(() => cantidad--);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(cantidad.toString(), style: const TextStyle(fontSize: 20)),
                IconButton(
                  onPressed: () {
                    if (cantidad < stock) setState(() => cantidad++);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
              ElevatedButton(onPressed: () => Navigator.pop(context, cantidad), child: const Text("Añadir")),
            ],
          );
        });
      },
    );

    if (result == null) return;
    cantidad = result;

    final carritoRef = FirebaseFirestore.instance.collection("carrito").doc(user.uid);
    final doc = await carritoRef.get();

    List<Map<String, dynamic>> productos = [];
    if (doc.exists) {
      productos = List<Map<String, dynamic>>.from(doc['productos'] ?? []);
    }

    final index = productos.indexWhere((p) => p['productoId'] == id);

    if (index >= 0) {
      int nuevaCantidad = productos[index]['cantidad'] + cantidad;
      if (nuevaCantidad > stock) nuevaCantidad = stock;
      productos[index]['cantidad'] = nuevaCantidad;
      productos[index]['total'] = productos[index]['precio'] * nuevaCantidad;
    } else {
      productos.add({
        'productoId': id,
        'nombre': nombre,
        'precio': precio,
        'cantidad': cantidad,
        'total': precio * cantidad,
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
        title: const Text("Tienda", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
            stream: FirebaseFirestore.instance.collection('productos').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _EmptyCart();
              }

              final productos = snapshot.data!.docs;
              return LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth < 600 ? 2 : constraints.maxWidth < 900 ? 3 : 4;
                  double childAspectRatio = constraints.maxWidth < 600 ? 0.65 : constraints.maxWidth < 900 ? 0.7 : 0.75;

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
                      final stock = data['stock'] ?? 0;
                      final agotado = stock <= 0;

                      return ProductoCard(
                        id: id,
                        nombre: data['nombre'],
                        descripcion: data['descripcion'],
                        precio: (data['precio'] as num).toDouble(),
                        imagenUrl: data['imagenUrl'],
                        enCarrito: enCarrito,
                        agotado: agotado,
                        onAdd: agotado
                            ? null
                            : () => _addToCart(
                                  id,
                                  data['nombre'],
                                  (data['precio'] as num).toDouble(),
                                  stock,
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

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D6EFD), Color(0xFF4EA8FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 24),
              const Text(
                "¡Vaya! Tu carrito está vacío",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Añade tus productos favoritos y estarán aquí.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.storefront_rounded),
                label: const Text("Ir a la tienda", style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class ProductoCard extends StatelessWidget {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final bool enCarrito;
  final bool agotado;
  final VoidCallback? onAdd;

  const ProductoCard({
    super.key,
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.enCarrito,
    this.agotado = false,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(imagenUrl, fit: BoxFit.cover, width: double.infinity),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("\$${precio.toStringAsFixed(2)}"),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: onAdd,
                      child: Text(enCarrito ? "En carrito" : "Añadir"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (agotado)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "AGOTADO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
