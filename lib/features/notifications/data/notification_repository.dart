import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stackhive/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  // Create Notification
  Future<void> createNotification({
    required String receiverId,
    required NotificationModel notification,
  }) async { 
    
    final docRef = _firestore
        .collection('users')
        .doc(receiverId)
        .collection('notifications')
        .doc();

    await docRef.set(notification.toMap());    
  }

  // Real-time Notifications Stream
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshots) => snapshots.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Mark Single As Read
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
  }

  // Mark All As Read
  Future<void> markAllRead(String userId) async {
    final batch = _firestore.batch();

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }    

    await batch.commit();
  }

  // Delete Notification
  Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // Clear All Notifications
  Future<void> clearAllNotifications(String userId) async {
    final snapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('notifications')
      .get();

    final batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}