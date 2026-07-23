import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String? profilePicture;
  final String role; // ✅ ADD THIS
  
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;
  final String? fitnessGoal;
  final List<String>? healthConditions;

  const AuthEntity({
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.profilePicture,
    this.role = 'user', // ✅ ADD THIS
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.fitnessGoal,
    this.healthConditions,
  });

  // ✅ ADD THIS METHOD
  factory AuthEntity.fromJson(Map<String, dynamic> json) {
    return AuthEntity(
      userId: json['_id'] ?? json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: '',
      profilePicture: json['profilePicture'],
      role: json['role'] ?? 'user',
      age: json['age'],
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      gender: json['gender'],
      fitnessGoal: json['fitnessGoal'],
      healthConditions: json['healthConditions'] != null
          ? List<String>.from(json['healthConditions'])
          : null,
    );
  }

  String get displayName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        userId,
        firstName,
        lastName,
        email,
        phone,
        password,
        profilePicture,
        role, // ✅ ADD THIS
        age,
        weight,
        height,
        gender,
        fitnessGoal,
        healthConditions,
      ];
}