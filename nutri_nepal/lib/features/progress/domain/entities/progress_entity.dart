import 'package:equatable/equatable.dart';

class ProgressPointEntity extends Equatable {
  final String label;
  final DateTime? date;
  final double weight;
  final double calories;

  const ProgressPointEntity({
    required this.label,
    required this.date,
    required this.weight,
    required this.calories,
  });

  @override
  List<Object?> get props => [label, date, weight, calories];
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
