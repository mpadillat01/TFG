import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 55,
              backgroundImage: AssetImage('assets/images/default_avatar.png'),
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'Paciente',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD)),
            ),
            const SizedBox(height: 6),
            Text(user?.email ?? '-', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Column(
                children: [
                  _item(Icons.person_outline, 'Editar perfil', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidad en desarrollo')),
                    );
                  }),
                  const Divider(height: 0, thickness: .8, indent: 60, endIndent: 20),
                  _item(Icons.help_outline, 'Centro de ayuda', () {}),
                  const Divider(height: 0, thickness: .8, indent: 60, endIndent: 20),
                  _item(Icons.privacy_tip_outlined, 'Política de privacidad', () {}),
                ],
              ),
            ),
            const SizedBox(height: 36),
            if (user != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  ListTile _item(IconData i, String t, VoidCallback onTap) {
    return ListTile(
      leading: Icon(i, color: const Color(0xFF0D6EFD)),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
