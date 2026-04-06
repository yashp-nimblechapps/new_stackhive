import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/auth/provider/authStateProvider.dart';
import 'package:stackhive/features/notifications/data/notification_settings_repository.dart';
import 'package:stackhive/models/notification_settings_model.dart';

final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
      return NotificationSettingsRepository(FirebaseFirestore.instance);
    });

final notificationSettingsProvider = StreamProvider<NotificationSettingsModel>((
  ref,
) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.empty();
  }

  final repo = ref.watch(notificationSettingsRepositoryProvider);
  return repo.watchSettings(user.uid);
});

final updateNotificationSettingsProvider =
    Provider<Future<void> Function(NotificationSettingsModel)>((ref) {
      final repo = ref.watch(notificationSettingsRepositoryProvider);

      return (NotificationSettingsModel settings) async {
        final user = ref.watch(authStateProvider).value;
        if (user == null) return;

        await repo.updateSettings(user.uid, settings);
      };
});
