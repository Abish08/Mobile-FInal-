import 'package:nutri_nepal/core/constants/hive_table_constant.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0) final String userId;
  @HiveField(1) final String firstName;
  @HiveField(2) final String lastName;
  @HiveField(3) final String phone;
  @HiveField(4) final String email;
  @HiveField(5) final String password;
  @HiveField(6) final String profilePicture;
  
  @HiveField(7) final int? age;
  @HiveField(8) final double? weight;
  @HiveField(9) final double? height;
  @HiveField(10) final String? gender;
  @HiveField(11) final String? fitnessGoal;
  @HiveField(12) final List<String>? healthConditions;
  @HiveField(13) final String role; // ✅ ADDED ROLE FIELD

  AuthHiveModel({
    String? userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    this.profilePicture = 'default-profile.png',
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.fitnessGoal,
    this.healthConditions,
    this.role = 'user', // ✅ ADDED ROLE DEFAULT
  }) : userId = userId ?? const Uuid().v4();

  factory AuthHiveModel.fromJson(Map<String, dynamic> json) {
    return AuthHiveModel(
      userId: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: '',
      profilePicture: json['profilePicture'] ?? 'default-profile.png',
      age: json['age'],
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      gender: json['gender'],
      fitnessGoal: json['fitnessGoal'],
      healthConditions: json['healthConditions'] != null
          ? List<String>.from(json['healthConditions'])
          : [],
      role: json['role'] ?? 'user', // ✅ ADDED ROLE PARSING
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'profilePicture': profilePicture,
      'role': role, // ✅ ADDED TO JSON
    };
  }

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId ?? const Uuid().v4(),
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      email: entity.email,
      password: entity.password,
      profilePicture: entity.profilePicture ?? 'default-profile.png',
      age: entity.age,
      weight: entity.weight,
      height: entity.height,
      gender: entity.gender,
      fitnessGoal: entity.fitnessGoal,
      healthConditions: entity.healthConditions,
      role: entity.role, // ✅ ADDED FROM ENTITY
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      password: password,
      profilePicture: profilePicture,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      fitnessGoal: fitnessGoal,
      healthConditions: healthConditions,
      role: role, // ✅ ADDED TO ENTITY
    );
  }
}