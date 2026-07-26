import 'package:nutri_nepal/features/health_profile/domain/entities/health_profile_entity.dart';

class HealthProfileModel extends HealthProfileEntity {
  const HealthProfileModel({
    super.id,
    super.userId,
    required super.age,
    required super.weight,
    required super.height,
    required super.gender,
    required super.fitnessGoal,
    super.healthConditions,
    super.activityLevel,
    super.goal,
    super.bmi,
    super.bmr,
    super.tdee,
    super.targetCalories,
    super.macros,
  });

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) {
    final goal = (json['goal'] ?? 'maintain').toString();
    return HealthProfileModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      userId: json['userId']?.toString(),
      age: _toInt(json['age']),
      weight: _toDouble(json['weight']),
      height: _toDouble(json['height']),
      gender: (json['gender'] ?? '').toString(),
      fitnessGoal: (json['fitnessGoal'] ?? _fitnessGoalFromGoal(goal)).toString(),
      healthConditions: json['healthConditions'] is List
          ? List<String>.from(json['healthConditions'])
          : const [],
      activityLevel: (json['activityLevel'] ?? 'moderate').toString(),
      goal: goal,
      bmi: json['bmi'] == null ? null : _toDouble(json['bmi']),
      bmr: json['bmr'] == null ? null : _toInt(json['bmr']),
      tdee: json['tdee'] == null ? null : _toInt(json['tdee']),
      targetCalories: json['targetCalories'] == null
          ? null
          : _toInt(json['targetCalories']),
      macros: json['macros'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['macros'])
          : null,
    );
  }

  factory HealthProfileModel.fromEntity(HealthProfileEntity entity) {
    return HealthProfileModel(
      id: entity.id,
      userId: entity.userId,
      age: entity.age,
      weight: entity.weight,
      height: entity.height,
      gender: entity.gender,
      fitnessGoal: entity.fitnessGoal,
      healthConditions: entity.healthConditions,
      activityLevel: entity.activityLevel,
      goal: entity.goal,
      bmi: entity.bmi,
      bmr: entity.bmr,
      tdee: entity.tdee,
      targetCalories: entity.targetCalories,
      macros: entity.macros,
    );
  }

  Map<String, dynamic> toUserProfileJson() {
    return {
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'fitnessGoal': fitnessGoal,
      'healthConditions': healthConditions,
    };
  }

  Map<String, dynamic> toHealthProfileJson() {
    return {
      ...toUserProfileJson(),
      'activityLevel': activityLevel,
      'goal': goal,
    };
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static String _fitnessGoalFromGoal(String goal) {
    switch (goal) {
      case 'lose':
        return 'lose_weight';
      case 'gain':
        return 'gain_muscle';
      case 'maintain':
      default:
        return 'maintain';
    }
  }
}
