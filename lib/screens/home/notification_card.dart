import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String type;
  final DateTime? date;

  const NotificationCard({
    super.key, 
    required this.title,
    required this.message,
    required this.type,
    this.date,
  });

  IconData _getIcon() {
    switch (type) {
      case "recordatorio":
        return Icons.event_available;
      case "admin":
        return Icons.verified_user_rounded;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor() {
    switch (type) {
      case "recordatorio":
        return Colors.yellowAccent.shade400;
      case "admin":
        return Colors.redAccent.shade400;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_getIcon(), color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.85),
                    fontSize: 14,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year} "
                    "• ${date!.hour.toString().padLeft(2, '0')}:${date!.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
