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
  createdAt: _timestampFromJson(json['createdAt']),
);

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'displayName': instance.displayName,
  'email': instance.email,
  'photoUrl': instance.photoUrl,
  'role': _$UserRoleEnumMap[instance.role]!,
  'createdAt': ?_timestampToJson(instance.createdAt),
};

const _$UserRoleEnumMap = {
  UserRole.client: 'client',
  UserRole.worker: 'worker',
};
