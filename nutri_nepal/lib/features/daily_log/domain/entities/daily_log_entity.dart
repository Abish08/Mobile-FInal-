import 'package:equatable/equatable.dart';

class DailyLogItemEntity extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final double calories;
  final Map<String, dynamic> raw;

  const DailyLogItemEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.raw,
  });

  @override
  List<Object?> get props => [id, title, subtitle, calories, raw];
}

class DailyLogEntity extends Equatable {
  final List<DailyLogItemEntity> foodLogs;
  final List<DailyLogItemEntity> workoutLogs;
  final double consumedCalories;
  final double burnedCalories;
  final double protein;
  final double carbs;
  final double fats;

  const DailyLogEntity({
    required this.foodLogs,
    required this.workoutLogs,
    required this.consumedCalories,
    required this.burnedCalories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  @override
  List<Object?> get props => [
    foodLogs,
    workoutLogs,
    consumedCalories,
    burnedCalories,
    protein,
    carbs,
    fats,
  ];
}
