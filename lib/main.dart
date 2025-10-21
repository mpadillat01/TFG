import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // 👈 importante
import 'package:trabajo_fin_grado/screens/auth/login_screen.dart';
import 'package:trabajo_fin_grado/screens/auth/register_screen.dart';
import 'package:trabajo_fin_grado/screens/home/appointments_screen.dart';
import 'package:trabajo_fin_grado/widgets/navigation/bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null); // 👈 añade esto antes del runApp

  runApp(const PodologiaApp());
}

class PodologiaApp extends StatelessWidget {
  const PodologiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Podología Profesional',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D6EFD),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/appointments': (context) => const AppointmentsScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const BottomNav(),
      },
    );
  }
}
