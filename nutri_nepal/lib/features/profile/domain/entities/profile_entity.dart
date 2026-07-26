import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profilePicture;
  final String? profilePictureUrl;
  final int? age;
  final double? weight;
  final double? height;
  final String? gender;
  final String? fitnessGoal;
  final List<String> healthConditions;
  final String role;

  const ProfileEntity({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profilePicture,
    this.profilePictureUrl,
    this.age,
    this.weight,
    this.height,
    this.gender,
    this.fitnessGoal,
    this.healthConditions = const [],
    this.role = 'user',
  });

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'User' : name;
  }

  @override
  List<Object?> get props => [
    userId,
    firstName,
    lastName,
    email,
    phone,
    profilePicture,
    profilePictureUrl,
    age,
    weight,
    height,
    gender,
    fitnessGoal,
    healthConditions,
    role,
  ];
}
