// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerProfile _$WorkerProfileFromJson(Map<String, dynamic> json) =>
    WorkerProfile(
      uid: json['uid'] as String,
      services: (json['services'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      bio: json['bio'] as String,
      rating: (json['rating'] as num).toDouble(),
      isVerified: json['isVerified'] as bool,
      subscriptionStatus: $enumDecode(
        _$SubscriptionStatusEnumMap,
        json['subscriptionStatus'],
      ),
    );

Map<String, dynamic> _$WorkerProfileToJson(WorkerProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'services': instance.services,
      'bio': instance.bio,
      'rating': instance.rating,
      'isVerified': instance.isVerified,
      'subscriptionStatus':
          _$SubscriptionStatusEnumMap[instance.subscriptionStatus]!,
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.free: 'free',
  SubscriptionStatus.basic: 'basic',
  SubscriptionStatus.premium: 'premium',
};
