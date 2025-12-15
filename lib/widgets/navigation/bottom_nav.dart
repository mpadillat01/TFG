

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trabajo_fin_grado/screens/auth/login_screen.dart';
import 'package:trabajo_fin_grado/screens/home/appointments_screen.dart';
import 'package:trabajo_fin_grado/screens/home/market_screen.dart';
import 'package:trabajo_fin_grado/screens/home/my_appointments_screen.dart';
import 'package:trabajo_fin_grado/screens/home/notification_screen.dart';
import 'package:trabajo_fin_grado/screens/home/profile_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _index = 0;

  final _screens = const [
    AppointmentsScreen(), 
    MyAppointmentsScreen(), 
    NotificationScreen(), 
    ProfileScreen(), 
  ];

  Future<void> _select(int i) async {
    if (i == 4) {
      _openMarket();
      return;
    }

    final requiresLogin = i != 0;
    final logged = FirebaseAuth.instance.currentUser != null;

    if (requiresLogin && !logged) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (ok != true) return;
    }

    setState(() => _index = i);
  }

  void _openMarket() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MarketScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final primaryBlue = colorScheme.primary; 
    
    final railBackgroundColor = Color.lerp(colorScheme.surface, primaryBlue.withOpacity(0.05), 0.1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 600;

        if (isWeb) {
          return Scaffold(
            backgroundColor: colorScheme.background,

            appBar: AppBar(
              title: Text(
                "Podología Gloria Mostazo",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: primaryBlue, 
                ),
              ),
              backgroundColor: colorScheme.surface,
              elevation: 4,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: primaryBlue), 
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: "Abrir Menú",
                ),
              ),
            ),

            drawer: NavigationDrawer(
              backgroundColor: railBackgroundColor,
              selectedIndex: _index,
              onDestinationSelected: (i) {
                Navigator.pop(context);
                _select(i);
              },
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 16, 16),
                  child: Text(
                    "Menú Principal",
                    style: GoogleFonts.montserrat(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
                const Divider(),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: Text('Citas'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.assignment_outlined),
                  label: Text('Mis Citas'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.notifications_none),
                  label: Text('Notificaciones'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.person_outline),
                  label: Text('Perfil'),
                ),
                const Divider(),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.storefront_outlined),
                  label: Text('Tienda'),
                ),
              ],
            ),

            body: Center(
              child: _screens[_index],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Podología Gloria Mostazo",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              actions: const [],
              elevation: 4,
            ),
            
            body: _screens[_index],
            
            bottomNavigationBar: NavigationBar(
              elevation: 8.0,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: _index,
              onDestinationSelected: _select,
              backgroundColor: colorScheme.surface,
              indicatorColor: primaryBlue.withOpacity(0.2),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Citas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: 'Mis Citas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_none),
                  selectedIcon: Icon(Icons.notifications),
                  label: 'Notificaciones',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Perfil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront),
                  label: 'Tienda',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}