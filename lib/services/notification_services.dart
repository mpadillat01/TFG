import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Inicialización segura según plataforma
  static Future<void> init() async {
    if (kIsWeb) {
      print("🔕 Notificaciones deshabilitadas en Web");
      return; // ❌ IMPORTANTE: NO intentar inicializar en Web
    }

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);
    print("📡 Notificaciones inicializadas correctamente");
  }

  /// Programar recordatorio (solo Android/iOS)
  static Future<void> scheduleAppointmentReminder({
    required DateTime appointmentDate,
    required String doctor,
  }) async {
    if (kIsWeb) return; // ❌ Ignorar en Web para evitar errores

    final tzDate = tz.TZDateTime.from(appointmentDate, tz.local);
    final reminderTime = tzDate.subtract(const Duration(hours: 1));

    if (reminderTime.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        reminderTime.millisecondsSinceEpoch ~/ 1000,
        'Recordatorio de cita',
        'Tienes una cita con $doctor en 1 hora',
        reminderTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'cita_channel',
            'Recordatorios de citas',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
