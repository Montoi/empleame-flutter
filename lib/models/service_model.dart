import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore-ready service model shared by the worker form and the
/// existing ServiceDetailScreen.
class ServiceModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final double rate;
  final String workerId;

  /// Remote image URLs stored in Firestore.
  /// On Spark plan these are placeholder URLs (e.g. picsum.photos).
  final List<String> imageUrls;

  /// 'pending_review' | 'active' | 'rejected'
  final String status;

  /// Optional reasoning when an admin rejects a service
  final String? adminNotes;

  final Timestamp? createdAt;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.rate,
    required this.workerId,
    this.imageUrls = const [],
    this.status = 'pending_review',
    this.adminNotes,
    this.createdAt,
  });

  // ── Firestore serialization ────────────────────────────────────────────────

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      title: d['title'] as String? ?? '',
      category: d['category'] as String? ?? '',
      description: d['description'] as String? ?? '',
      rate: (d['rate'] as num? ?? 0).toDouble(),
      workerId: d['workerId'] as String? ?? '',
      imageUrls: List<String>.from(d['imageUrls'] as List? ?? []),
      status: d['status'] as String? ?? 'pending_review',
      adminNotes: d['adminNotes'] as String?,
      createdAt: d['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'category': category,
    'description': description,
    'rate': rate,
    'workerId': workerId,
    'imageUrls': imageUrls,
    'status': status,
    if (adminNotes != null) 'adminNotes': adminNotes,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };

  ServiceModel copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    double? rate,
    String? workerId,
    List<String>? imageUrls,
    String? status,
    String? adminNotes,
    Timestamp? createdAt,
  }) => ServiceModel(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    description: description ?? this.description,
    rate: rate ?? this.rate,
    workerId: workerId ?? this.workerId,
    imageUrls: imageUrls ?? this.imageUrls,
    status: status ?? this.status,
    adminNotes: adminNotes ?? this.adminNotes,
    createdAt: createdAt ?? this.createdAt,
  );
}
