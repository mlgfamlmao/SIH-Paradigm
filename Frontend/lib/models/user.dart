import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String deviceId;
  final String? ageGroup;
  final String? gender;
  final int? householdSize;
  final bool consentGiven;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.deviceId,
    this.ageGroup,
    this.gender,
    this.householdSize,
    required this.consentGiven,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? deviceId,
    String? ageGroup,
    String? gender,
    int? householdSize,
    bool? consentGiven,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      ageGroup: ageGroup ?? this.ageGroup,
      gender: gender ?? this.gender,
      householdSize: householdSize ?? this.householdSize,
      consentGiven: consentGiven ?? this.consentGiven,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class UserCreate {
  final String deviceId;
  final String? ageGroup;
  final String? gender;
  final int? householdSize;
  final bool consentGiven;

  UserCreate({
    required this.deviceId,
    this.ageGroup,
    this.gender,
    this.householdSize,
    required this.consentGiven,
  });

  factory UserCreate.fromJson(Map<String, dynamic> json) => _$UserCreateFromJson(json);
  Map<String, dynamic> toJson() => _$UserCreateToJson(this);
}

@JsonSerializable()
class UserUpdate {
  final String? ageGroup;
  final String? gender;
  final int? householdSize;
  final bool? consentGiven;

  UserUpdate({
    this.ageGroup,
    this.gender,
    this.householdSize,
    this.consentGiven,
  });

  factory UserUpdate.fromJson(Map<String, dynamic> json) => _$UserUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$UserUpdateToJson(this);
}
