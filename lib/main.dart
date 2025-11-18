import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_option.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/appointments_screen.dart';
import 'widgets/navigation/bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('es_ES', null);

  runApp(const PodologiaApp());
}


class PodologiaApp extends StatelessWidget {
  const PodologiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D6EFD)),
      scaffoldBackgroundColor: const Color(0xFFF5F9FF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D6EFD),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
    );

    return MaterialApp(
      title: 'Podología Profesional',
      debugShowCheckedModeBanner: false,
      theme: base,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/home',
      routes: {
        '/home': (_) => const BottomNav(),
        '/appointments': (_) => const AppointmentsScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
      },
    );
  }
}
