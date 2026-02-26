import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole { client, worker }

@JsonSerializable(explicitToJson: true)
class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final UserRole role;

  /// This user's invitation code. Defaults to their UID.
  @JsonKey(defaultValue: '')
  final String referralCode;

  /// How many more workers this user can invite. 0 = cannot invite.
  @JsonKey(defaultValue: 0)
  final int availableUpdates;

  /// UID of the user who referred this user (set on worker conversion).
  final String? referredBy;

  @JsonKey(
    fromJson: _timestampFromJson,
    toJson: _timestampToJson,
    includeIfNull: false,
  )
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.role,
    this.referralCode = '',
    this.availableUpdates = 0,
    this.referredBy,
    this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser.fromJson(data);
  }

  AppUser copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    UserRole? role,
    String? referralCode,
    int? availableUpdates,
    String? referredBy,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      referralCode: referralCode ?? this.referralCode,
      availableUpdates: availableUpdates ?? this.availableUpdates,
      referredBy: referredBy ?? this.referredBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

DateTime? _timestampFromJson(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  return null;
}

dynamic _timestampToJson(DateTime? date) {
  if (date == null) return null;
  return Timestamp.fromDate(date);
}
