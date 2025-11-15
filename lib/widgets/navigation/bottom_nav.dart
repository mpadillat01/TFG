import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabajo_fin_grado/screens/home/appointments_screen.dart';
import 'package:trabajo_fin_grado/screens/home/my_appointments_screen.dart';
import 'package:trabajo_fin_grado/screens/home/notification_screen.dart';
import 'package:trabajo_fin_grado/screens/home/profile_screen.dart';
import 'package:trabajo_fin_grado/screens/auth/login_screen.dart';

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
    final logged = FirebaseAuth.instance.currentUser != null;
    final requiresLogin = i != 0;
    if (requiresLogin && !logged) {
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (ok == true) {
        setState(() => _index = i);
      }
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Citas'),
          NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Mis Citas'),
          NavigationDestination(
              icon: Icon(Icons.notifications_none),
              selectedIcon: Icon(Icons.notifications),
              label: 'Notificaciones'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil'),
        ],
      ),
    );
  }
}
