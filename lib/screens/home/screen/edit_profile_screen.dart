import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = user?.displayName ?? "";
    _emailCtrl.text = user?.email ?? "";
  }

  Future<void> _saveChanges() async {
    setState(() => _loading = true);

    try {
      if (_nameCtrl.text.isNotEmpty && _nameCtrl.text != user?.displayName) {
        await user!.updateDisplayName(_nameCtrl.text);
      }

      if (_emailCtrl.text.isNotEmpty && _emailCtrl.text != user?.email) {
        await user!.updateEmail(_emailCtrl.text);
      }

      if (_passwordCtrl.text.isNotEmpty) {
        if (_passwordCtrl.text.length < 6) {
          throw Exception("La contraseña debe tener al menos 6 caracteres");
        }
        if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
          throw Exception("Las contraseñas no coinciden");
        }
        await user!.updatePassword(_passwordCtrl.text);
      }

      await user!.reload();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perfil actualizado correctamente"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0D6EFD),
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 500 : width),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTextField(_nameCtrl, "Nombre completo"),
                      const SizedBox(height: 18),
                      _buildTextField(_emailCtrl, "Correo electrónico"),
                      const SizedBox(height: 18),
                      _buildTextField(
                        _passwordCtrl,
                        "Nueva contraseña (opcional)",
                        obscure: true,
                      ),
                      const SizedBox(height: 18),
                      _buildTextField(
                        _confirmPasswordCtrl,
                        "Repetir nueva contraseña",
                        obscure: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(.3),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.blue)
                        : const Text(
                            "Guardar cambios",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(.4)),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
