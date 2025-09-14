// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int,
      deviceId: json['device_id'] as String,
      ageGroup: json['age_group'] as String?,
      gender: json['gender'] as String?,
      householdSize: json['household_size'] as int?,
      consentGiven: json['consent_given'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceId,
      'age_group': instance.ageGroup,
      'gender': instance.gender,
      'household_size': instance.householdSize,
      'consent_given': instance.consentGiven,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

UserCreate _$UserCreateFromJson(Map<String, dynamic> json) => UserCreate(
      deviceId: json['device_id'] as String,
      ageGroup: json['age_group'] as String?,
      gender: json['gender'] as String?,
      householdSize: json['household_size'] as int?,
      consentGiven: json['consent_given'] as bool,
    );

Map<String, dynamic> _$UserCreateToJson(UserCreate instance) => <String, dynamic>{
      'device_id': instance.deviceId,
      'age_group': instance.ageGroup,
      'gender': instance.gender,
      'household_size': instance.householdSize,
      'consent_given': instance.consentGiven,
    };

UserUpdate _$UserUpdateFromJson(Map<String, dynamic> json) => UserUpdate(
      ageGroup: json['age_group'] as String?,
      gender: json['gender'] as String?,
      householdSize: json['household_size'] as int?,
      consentGiven: json['consent_given'] as bool?,
    );

Map<String, dynamic> _$UserUpdateToJson(UserUpdate instance) => <String, dynamic>{
      'age_group': instance.ageGroup,
      'gender': instance.gender,
      'household_size': instance.householdSize,
      'consent_given': instance.consentGiven,
    };
