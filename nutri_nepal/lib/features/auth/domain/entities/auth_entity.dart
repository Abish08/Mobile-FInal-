import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  
  // ✅ THIS IS THE MISSING FIELD
  final String? profilePicture; 
  
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
    this.profilePicture, // ✅ MUST BE HERE
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.fitnessGoal,
    this.healthConditions,
  });

  String get displayName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        userId,
        firstName,
        lastName,
        email,
        phone,
        password,
        profilePicture, // ✅ MUST BE HERE
        age,
        weight,
        height,
        gender,
        fitnessGoal,
        healthConditions,
      ];
}