import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single notification persisted in
/// `users/{uid}/notifications_history`.
class NotificationModel {
  final String id;
  final String title;
  final String body;

  /// Optional service ID for deep-linking to ServiceDetailScreen.
  final String? serviceId;

  /// Whether the user has seen/tapped this notification.
  final bool isRead;

  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.serviceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final data = d['data'] as Map<String, dynamic>? ?? {};
    final ts = d['createdAt'];
    return NotificationModel(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      serviceId: data['serviceId'] as String?,
      isRead: d['isRead'] as bool? ?? false,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'data': {if (serviceId != null) 'serviceId': serviceId},
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        serviceId: serviceId,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
