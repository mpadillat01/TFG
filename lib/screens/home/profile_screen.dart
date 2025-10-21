import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _email;
  String _name = "Mario Padilla"; 
  String _profileImage = "assets/images/default_avatar.png";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('logged_email') ?? "usuario@correo.com";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sesión cerrada correctamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: const Color(0xFF0D6EFD),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 12),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(_profileImage),
              ),
            ),

            Text(
              _name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D6EFD),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _email ?? "",
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 30),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Column(
                children: [
                  _buildOption(
                    icon: Icons.person_outline,
                    text: "Editar perfil",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Funcionalidad en desarrollo")),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildOption(
                    icon: Icons.help_outline,
                    text: "Centro de ayuda",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildOption(
                    icon: Icons.privacy_tip_outlined,
                    text: "Política de privacidad",
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            GestureDetector(
              onTap: _logout,
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF0D6EFD)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Cerrar sesión",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D6EFD)),
      title: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 0, thickness: 0.8, indent: 60, endIndent: 20);
  }
}
