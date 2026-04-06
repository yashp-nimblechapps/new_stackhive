import 'package:flutter/material.dart';
import 'package:stackhive/models/notification_settings_model.dart';

bool isQuietHours(NotificationSettingsModel settings) {
  if (!settings.quietHoursEnabled) return false;

  final now = TimeOfDay.now();

  final startParts = settings.quietStart.split(':');
  final endParts = settings.quietEnd.split(':');

  final start = TimeOfDay(
    hour: int.parse(startParts[0]),
    minute: int.parse(startParts[1]),
  );

  final end = TimeOfDay(
    hour: int.parse(endParts[0]),
    minute: int.parse(endParts[1]),
  );

  final nowMinutes = now.hour * 60 + now.minute;
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;

  // Example: 22:00 → 07:00 (cross midnight)
  if (startMinutes > endMinutes) {
    return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
  }

  return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
}
