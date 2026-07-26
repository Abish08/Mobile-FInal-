import 'package:equatable/equatable.dart';

class HealthProfileEntity extends Equatable {
  final String? id;
  final String? userId;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String fitnessGoal;
  final List<String> healthConditions;
  final String activityLevel;
  final String goal;
  final double? bmi;
  final int? bmr;
  final int? tdee;
  final int? targetCalories;
  final Map<String, dynamic>? macros;

  const HealthProfileEntity({
    this.id,
    this.userId,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.fitnessGoal,
    this.healthConditions = const [],
    this.activityLevel = 'moderate',
    this.goal = 'maintain',
    this.bmi,
    this.bmr,
    this.tdee,
    this.targetCalories,
    this.macros,
  });

  HealthProfileEntity copyWith({
    String? id,
    String? userId,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? fitnessGoal,
    List<String>? healthConditions,
    String? activityLevel,
    String? goal,
    double? bmi,
    int? bmr,
    int? tdee,
    int? targetCalories,
    Map<String, dynamic>? macros,
  }) {
    return HealthProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      healthConditions: healthConditions ?? this.healthConditions,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      bmi: bmi ?? this.bmi,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      targetCalories: targetCalories ?? this.targetCalories,
      macros: macros ?? this.macros,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        age,
        weight,
        height,
        gender,
        fitnessGoal,
        healthConditions,
        activityLevel,
        goal,
        bmi,
        bmr,
        tdee,
        targetCalories,
        macros,
      ];
}
