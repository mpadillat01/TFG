import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    Uint8List? imageBytes;
    if (imagenUrl.startsWith("data:image")) {
      try {
        final base64Str = imagenUrl.split(',')[1];
        imageBytes = base64Decode(base64Str);
      } catch (e) {
        debugPrint("Error decodificando Base64: $e");
      }
    }

    final bool userLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: imageBytes != null
                        ? Image.memory(imageBytes, fit: BoxFit.cover)
                        : imagenUrl.startsWith("http")
                            ? Image.network(
                                imagenUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                              )
                            : Image.asset(imagenUrl, fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        descripcion,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${precio.toStringAsFixed(2)} €",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: Color(0xFF0D6EFD),
                            ),
                          ),
                          _buildAddButton(userLoggedIn),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (agotado)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "AGOTADO",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(bool userLoggedIn) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (userLoggedIn && !agotado) ? onAdd : null,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: enCarrito 
                ? Colors.green 
                : (userLoggedIn && !agotado ? const Color(0xFF0D6EFD) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            enCarrito ? Icons.check : Icons.add_shopping_cart,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}