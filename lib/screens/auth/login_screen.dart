import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:trabajo_fin_grado/services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final email = TextEditingController();
  final pass = TextEditingController();
  final auth = AuthService();
  bool loading = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scale = Tween<double>(
      begin: 0.78,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  Future<void> _login() async {
    setState(() => loading = true);
    try {
      await auth.signIn(email.text.trim(), pass.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al iniciar sesión: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Degradado animado elegante
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark
                    ? [
                        const Color(0xFF0F2027),
                        const Color(0xFF203A43),
                        const Color(0xFF2C5364),
                      ]
                    : [
                        const Color(0xFFdfe9f3),
                        const Color(0xFFf7f8f8),
                        const Color(0xFFFFFFFF),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🔵 Glow lateral tipo premium
          Positioned(
            top: -80,
            left: -40,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -90,
            right: -40,
            child: Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purpleAccent.withOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 🔙 BOTÓN VOLVER
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  children: [
                    // 🔥 LOGO -> efecto breathing + glow
                    ScaleTransition(
                      scale: _scale,
                      child: FadeTransition(
                        opacity: _fade,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.4),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/images/logo.png",
                            height: 120,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 🧊 TARJETA GLASS PREMIUM
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white.withOpacity(0.12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Bienvenido",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.85),
                                ),
                              ),

                              const SizedBox(height: 25),

                              // ✉️ EMAIL
                              _buildInput(
                                controller: email,
                                hint: "Email",
                                icon: Icons.email_rounded,
                                dark: dark,
                              ),

                              const SizedBox(height: 18),

                              // 🔒 CONTRASEÑA
                              _buildInput(
                                controller: pass,
                                hint: "Contraseña",
                                icon: Icons.lock_rounded,
                                obscure: true,
                                dark: dark,
                              ),

                              const SizedBox(height: 30),

                              // 🟦 BOTÓN CON GLOW
                              SizedBox(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: loading ? null : _login,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4A90E2),
                                          Color(0xFF357ABD),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blueAccent.withOpacity(
                                            0.5,
                                          ),
                                          blurRadius: 25,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        loading ? "Entrando..." : "Entrar",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Registrar
                              TextButton(
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushNamed('/register'),
                                child: Text(
                                  "Crear cuenta",
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.7),
                                    fontSize: 15,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ Input con diseño moderno y color mejorado
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool dark,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: Colors.black.withOpacity(0.85), fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.65), size: 22),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.black.withOpacity(0.45),
          fontSize: 15,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.65),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.25),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.blueAccent.withOpacity(0.7),
            width: 1.8,
          ),
        ),
      ),
    );
  }
}
