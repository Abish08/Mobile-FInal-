import 'package:nutri_nepal/core/constants/hive_table_constant.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final String password;

  @HiveField(6)
  final String profilePicture;

  AuthHiveModel({
    String? userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    this.profilePicture = 'default-profile.png',
  }) : userId = userId ?? const Uuid().v4();

  // Convert from API response (backend JSON)
  factory AuthHiveModel.fromJson(Map<String, dynamic> json) {
    final nameParts = (json['firstName'] ?? '').split(' ');
    return AuthHiveModel(
      userId: json['_id'] ?? json['id'] ?? '',
      firstName: nameParts.isNotEmpty ? nameParts[0] : '',
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: '', // Don't store password from API
      profilePicture: json['profilePicture'] ?? 'default-profile.png',
    );
  }

  // Convert to API request (for registration)
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  // Convert from Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId ?? const Uuid().v4(),
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      email: entity.email,
      password: entity.password,
    );
  }

  // Convert to Entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      password: password,
    );
  }
}