import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:nutri_nepal/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.userId,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    super.profilePicture,
    super.profilePictureUrl,
    super.age,
    super.weight,
    super.height,
    super.gender,
    super.fitnessGoal,
    super.healthConditions,
    super.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final profilePicture = _text(json['profilePicture']);
    return ProfileModel(
      userId: _text(json['_id']) ?? _text(json['id']) ?? '',
      firstName: _text(json['firstName']) ?? '',
      lastName: _text(json['lastName']) ?? '',
      email: _text(json['email']) ?? '',
      phone: _text(json['phone']) ?? '',
      profilePicture: profilePicture,
      profilePictureUrl: _profilePictureUrl(profilePicture),
      age: _toPositiveInt(json['age']),
      weight: _toPositiveDouble(json['weight']),
      height: _toPositiveDouble(json['height']),
      gender: _text(json['gender']),
      fitnessGoal: _text(json['fitnessGoal']),
      healthConditions: json['healthConditions'] is List
          ? List<String>.from(json['healthConditions'])
          : const [],
      role: _text(json['role']) ?? 'user',
    );
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      userId: entity.userId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      phone: entity.phone,
      profilePicture: entity.profilePicture,
      profilePictureUrl: entity.profilePictureUrl,
      age: entity.age,
      weight: entity.weight,
      height: entity.height,
      gender: entity.gender,
      fitnessGoal: entity.fitnessGoal,
      healthConditions: entity.healthConditions,
      role: entity.role,
    );
  }

  factory ProfileModel.fromAuth(AuthEntity entity) {
    return ProfileModel.fromJson({
      '_id': entity.userId,
      'firstName': entity.firstName,
      'lastName': entity.lastName,
      'email': entity.email,
      'phone': entity.phone,
      'profilePicture': entity.profilePicture,
      'age': entity.age,
      'weight': entity.weight,
      'height': entity.height,
      'gender': entity.gender,
      'fitnessGoal': entity.fitnessGoal,
      'healthConditions': entity.healthConditions,
      'role': entity.role,
    });
  }

  AuthEntity toAuthEntity() {
    return AuthEntity(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: '',
      profilePicture: profilePicture,
      role: role,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      fitnessGoal: fitnessGoal,
      healthConditions: healthConditions,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    };
  }

  static ProfileModel fromResponse(dynamic responseData) {
    final data = responseData is Map
        ? responseData['data'] ?? responseData['user'] ?? responseData
        : responseData;
    return ProfileModel.fromJson(Map<String, dynamic>.from(data as Map));
  }
}

String? _text(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _toPositiveInt(dynamic value) {
  final parsed = value is num ? value.toInt() : int.tryParse('$value');
  return parsed == null || parsed <= 0 ? null : parsed;
}

double? _toPositiveDouble(dynamic value) {
  final parsed = value is num ? value.toDouble() : double.tryParse('$value');
  if (parsed == null || parsed <= 0 || parsed.isNaN || parsed.isInfinite) {
    return null;
  }
  return parsed;
}

String? _profilePictureUrl(String? value) {
  if (value == null || value == 'default-profile.png') {
    return null;
  }
  return ApiEndpoints.resolveUploadUrl(value);
}
