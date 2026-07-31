import 'package:equatable/equatable.dart';

class ProgressPointEntity extends Equatable {
  final String label;
  final DateTime? date;
  final double weight;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double duration;

  const ProgressPointEntity({
    required this.label,
    required this.date,
    required this.weight,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    this.duration = 0,
  });

  @override
  List<Object?> get props => [
    label,
    date,
    weight,
    calories,
    protein,
    carbs,
    fats,
    duration,
  ];
}

class ProgressSummaryEntity extends Equatable {
  final double? startWeight;
  final double? currentWeight;

  const ProgressSummaryEntity({
    required this.startWeight,
    required this.currentWeight,
  });

  @override
  List<Object?> get props => [startWeight, currentWeight];
}

class ProgressEntity extends Equatable {
  final ProgressSummaryEntity summary;
  final List<ProgressPointEntity> calorieHistory;
  final List<ProgressPointEntity> workoutHistory;

  const ProgressEntity({
    required this.summary,
    required this.calorieHistory,
    required this.workoutHistory,
  });

  bool get isEmpty => calorieHistory.isEmpty && workoutHistory.isEmpty;

  @override
  List<Object?> get props => [summary, calorieHistory, workoutHistory];
}
