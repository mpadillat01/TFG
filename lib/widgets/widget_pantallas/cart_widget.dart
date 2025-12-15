import 'package:flutter/material.dart';
import 'package:trabajo_fin_grado/screens/home/carrito_screen.dart';

class CartWidget extends StatelessWidget {
  final int carritoCount;
  final Set<String> carrito;

  const CartWidget({
    super.key,
    required this.carritoCount,
    required this.carrito,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CarritoScreen(carritoIds: carrito),
              ),
            );
          },
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        ),
        if (carritoCount > 0)
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
                carritoCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
