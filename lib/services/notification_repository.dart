import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empleame/models/notification_model.dart';

/// Repository for reading and updating the notification history of a user.
/// Firestore path: users/{uid}/notifications_history
class NotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream of notifications for [uid], ordered newest-first.
  Stream<List<NotificationModel>> watchNotifications(String uid) {
    return _db
        .collection('users/$uid/notifications_history')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(NotificationModel.fromFirestore)
              .toList(),
        );
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(String uid, String notifId) async {
    await _db
        .collection('users/$uid/notifications_history')
        .doc(notifId)
        .update({'isRead': true});
  }

  /// Marks all notifications as read in a single batch.
  Future<void> markAllAsRead(String uid) async {
    final snap = await _db
        .collection('users/$uid/notifications_history')
        .where('isRead', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
