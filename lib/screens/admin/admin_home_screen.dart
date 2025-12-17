import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trabajo_fin_grado/screens/admin/add_product_screen.dart';
import 'package:trabajo_fin_grado/screens/admin/admin_citas_screen.dart';
import 'package:trabajo_fin_grado/screens/admin/admin_product_screen.dart';
import 'package:trabajo_fin_grado/screens/admin/mensajes_screen.dart';
import 'package:trabajo_fin_grado/widgets/navigation/bottom_nav.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const AdminCitasScreen(),
      const AdminMensajesScreen(),
      const AdminProductsScreen(),
      const AddProductoScreen(),
    ];
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BottomNav()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cerrar sesión: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _drawerItem({required IconData icon, required String title, required int index}) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700),
      title: Text(title,
          style: GoogleFonts.poppins(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.blue.shade700 : Colors.black87,
          )),
      selected: isSelected,
      selectedTileColor: Colors.blue.shade50,
      hoverColor: Colors.blue.shade100,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !isMobile,
        title: Text(
          "Panel de Administración",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D6EFD),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      drawer: !isMobile
          ? Drawer(
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D6EFD), Color(0xFF4EA8FF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Menú Admin",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _drawerItem(icon: Icons.calendar_month, title: "Citas", index: 0),
                        _drawerItem(icon: Icons.message, title: "Mensajes", index: 1),
                        _drawerItem(icon: Icons.list, title: "Productos", index: 2),
                        _drawerItem(icon: Icons.add, title: "Añadir Producto", index: 3),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: _screens[_currentIndex],
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: Colors.blue.shade700,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.poppins(),
              onTap: (i) => setState(() => _currentIndex = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: "Citas",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: "Mensajes",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: "Productos",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: "Añadir",
                ),
              ],
            )
          : null,
    );
  }
}
