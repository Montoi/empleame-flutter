import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'worker_profile_model.g.dart';

enum SubscriptionStatus { free, basic, premium }

@JsonSerializable(explicitToJson: true)
class WorkerProfile {
  final String uid;
  final List<String> services;
  final String bio;
  final double rating;
  final bool isVerified;
  final SubscriptionStatus subscriptionStatus;

  /// UID of the user who referred this worker.
  final String? referredBy;

  const WorkerProfile({
    required this.uid,
    required this.services,
    required this.bio,
    required this.rating,
    required this.isVerified,
    required this.subscriptionStatus,
    this.referredBy,
  });

  factory WorkerProfile.fromJson(Map<String, dynamic> json) =>
      _$WorkerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$WorkerProfileToJson(this);

  factory WorkerProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkerProfile.fromJson(data);
  }

  WorkerProfile copyWith({
    List<String>? services,
    String? bio,
    double? rating,
    bool? isVerified,
    SubscriptionStatus? subscriptionStatus,
    String? referredBy,
  }) {
    return WorkerProfile(
      uid: uid,
      services: services ?? this.services,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      referredBy: referredBy ?? this.referredBy,
    );
  }
}
