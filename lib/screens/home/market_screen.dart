import 'package:flutter/material.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final List<Map<String, dynamic>> _productos = [
    {
      "nombre": "Crema reparadora podal",
      "descripcion": "Hidratación profunda para pies secos.",
      "precio": 14.99,
      "imagen": "assets/images/crema_podal.png",
    },

    {
      "nombre": "Plantillas ortopédicas",
      "descripcion": "Amortiguan y corrigen la pisada.",
      "precio": 24.50,
      "imagen":
          "https://image.jimcdn.com/app/cms/image/transf/none/path/s83f2a0e918e52b5f/image/ibf89c6b3274c5e30/version/1365202675/image.png",
    },
    {
      "nombre": "Spray antifúngico",
      "descripcion": "Previene infecciones por hongos.",
      "precio": 9.99,
      "imagen":
          "data:image/jpeg;base64,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",
    },
    {
      "nombre": "Crema antirozaduras",
      "descripcion": "Protege la piel de fricciones.",
      "precio": 11.75,
      "imagen":
          "data:image/jpeg;base64,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",
    },
  ];
  final Set<int> _carrito = {};

  void _toggleCarrito(int index) {
    setState(() {
      _carrito.contains(index) ? _carrito.remove(index) : _carrito.add(index);
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
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
              ),
              if (_carrito.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _carrito.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
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
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _productos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.63,
            ),
            itemBuilder: (context, i) {
              final producto = _productos[i];
              final bool enCarrito = _carrito.contains(i);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        producto["imagen"],
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto["nombre"],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          Text(
                            producto["descripcion"],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(.55),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "${producto["precio"].toStringAsFixed(2)} €",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0D6EFD),
                            ),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _toggleCarrito(i),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                backgroundColor: enCarrito
                                    ? Colors.green.shade500
                                    : const Color(0xFF0D6EFD),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                enCarrito ? "Añadido" : "Añadir",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
