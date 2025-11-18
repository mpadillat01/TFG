import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity, // ⭐ asegura el fondo full-screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D6EFD), Color(0xFF4EA8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints
                        .maxHeight, // ⭐ el contenido rellena la pantalla
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // ⭐ Avatar con glow
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(.8),
                                Colors.white.withOpacity(.1),
                              ],
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 55,
                            backgroundImage: AssetImage(
                              "assets/images/default_avatar.png",
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          FirebaseAuth.instance.currentUser?.displayName ??
                              "Paciente",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          FirebaseAuth.instance.currentUser?.email ?? "-",
                          style: TextStyle(
                            color: Colors.white.withOpacity(.85),
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 30),

                        _glassCard(
                          child: Column(
                            children: [
                              _item(
                                icon: Icons.person_outline,
                                text: "Editar perfil",
                                onTap: () {},
                              ),
                              _divider(),
                              _item(
                                icon: Icons.help_outline,
                                text: "Centro de ayuda",
                                onTap: () {},
                              ),
                              _divider(),
                              _item(
                                icon: Icons.privacy_tip_outlined,
                                text: "Política de privacidad",
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              "Cerrar sesión",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (!context.mounted) return;

                              Navigator.of(context).pushNamedAndRemoveUntil(
                                "/login",
                                (route) => false,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ⭐ Estilo de tarjeta glass
  static Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.35)),
      ),
      child: child,
    );
  }

  // ⭐ Ítem estilizado
  Widget _item({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 26),
      title: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.white.withOpacity(.7)),
      onTap: onTap,
    );
  }

  // ⭐ Separador glass
  Widget _divider() {
    return Divider(
      color: Colors.white.withOpacity(.35),
      thickness: .7,
      indent: 12,
      endIndent: 12,
    );
  }
}
