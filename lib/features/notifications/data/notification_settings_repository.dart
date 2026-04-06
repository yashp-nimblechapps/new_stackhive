import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackhive/models/notification_settings_model.dart';

class NotificationSettingsRepository {
  final FirebaseFirestore _firestore;

  NotificationSettingsRepository(this._firestore);

  Stream<NotificationSettingsModel> watchSettings(String userId) {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notifications');

    return docRef.snapshots().asyncMap((doc) async {
      if (!doc.exists) {
        final defaults = NotificationSettingsModel.defaultSettings();

        await docRef.set(defaults.toMap());

        return defaults;
      }

      return NotificationSettingsModel.fromMap(doc.data()!);
    });
  }

  Future<void> updateSettings(
    String userId,
    NotificationSettingsModel settings,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notifications')
        .set(settings.toMap(), SetOptions(merge: true));
  }

  Future<NotificationSettingsModel> getSettings(String userId) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notifications');

    final doc = await docRef.get();

    if (!doc.exists) {
      final defaultSettings = NotificationSettingsModel.defaultSettings();

      await docRef.set(defaultSettings.toMap());
      return defaultSettings;
    }

    return NotificationSettingsModel.fromMap(doc.data()!);
  }
}
