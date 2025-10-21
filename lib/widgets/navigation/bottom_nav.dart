import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trabajo_fin_grado/screens/home/appointments_screen.dart';
import 'package:trabajo_fin_grado/screens/auth/login_screen.dart';
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
  bool _isLoggedIn = false;

  final List<Widget> _screens = const [
    AppointmentsScreen(),               
    MyAppointmentsScreen(),    
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isLoggedIn = prefs.getBool('logged_in') ?? false);
  }

  Future<void> _onTabTapped(int newIndex) async {
    if (!_isLoggedIn && newIndex != 0) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (result == true) {
        setState(() {
          _isLoggedIn = true;
          _index = newIndex;
        });
      }
      return;
    }
    setState(() => _index = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D6EFD),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Citas'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Mis Citas'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notificaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
