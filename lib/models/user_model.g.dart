// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
  uid: json['uid'] as String,
  displayName: json['displayName'] as String,
  email: json['email'] as String,
  photoUrl: json['photoUrl'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  referralCode: json['referralCode'] as String? ?? '',
  availableUpdates: (json['availableUpdates'] as num?)?.toInt() ?? 0,
  referredBy: json['referredBy'] as String?,
  nickname: json['nickname'] as String?,
  country: json['country'] as String?,
  phone: json['phone'] as String?,
  gender: json['gender'] as String?,
  address: json['address'] as String?,
  dateOfBirth: _timestampFromJson(json['dateOfBirth']),
  createdAt: _timestampFromJson(json['createdAt']),
  savedServices:
      (json['savedServices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  isMuted: json['isMuted'] as bool? ?? false,
);

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'displayName': instance.displayName,
  'email': instance.email,
  'photoUrl': instance.photoUrl,
  'role': _$UserRoleEnumMap[instance.role]!,
  'referralCode': instance.referralCode,
  'availableUpdates': instance.availableUpdates,
  'referredBy': instance.referredBy,
  'nickname': instance.nickname,
  'country': instance.country,
  'phone': instance.phone,
  'gender': instance.gender,
  'address': instance.address,
  'dateOfBirth': ?_timestampToJson(instance.dateOfBirth),
  'createdAt': ?_timestampToJson(instance.createdAt),
  'savedServices': instance.savedServices,
  'isMuted': instance.isMuted,
};

const _$UserRoleEnumMap = {
  UserRole.client: 'client',
  UserRole.worker: 'worker',
  UserRole.admin: 'admin',
};
