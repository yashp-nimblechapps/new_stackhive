import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stackhive/features/auth/provider/authStateProvider.dart';
import 'package:stackhive/features/notifications/data/notification_repository.dart';
import 'package:stackhive/models/notification_model.dart';

// Repository Provider 
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(FirebaseFirestore.instance);
});

// Notifications Stream Provider
final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) {
    return Stream.empty();
  }

  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotificationsStream(user.uid);
});

// Unread Count Provider
final unreadCountProvider = Provider<int>((ref) {   
  final notifications = ref.watch(notificationsStreamProvider);

  return notifications.when(
    data: (list) =>
        list.where((n) => n.isRead == false).length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});