import 'package:nutri_nepal/features/progress/domain/entities/progress_entity.dart';

class ProgressSummaryModel extends ProgressSummaryEntity {
  const ProgressSummaryModel({
    required super.startWeight,
    required super.currentWeight,
  });

  factory ProgressSummaryModel.fromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : const {};
    return ProgressSummaryModel(
      startWeight: _toFiniteDouble(map['startWeight']),
      currentWeight: _toFiniteDouble(map['currentWeight']),
    );
  }
}

class ProgressPointModel extends ProgressPointEntity {
  const ProgressPointModel({
    required super.label,
    required super.date,
    required super.weight,
    required super.calories,
    super.protein,
    super.carbs,
    super.fats,
    super.duration,
  });

  factory ProgressPointModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];
    final date = rawDate == null ? null : DateTime.tryParse(rawDate.toString());
    final fallbackLabel = date == null
        ? ''
        : '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return ProgressPointModel(
      label: (json['_id'] ?? fallbackLabel).toString(),
      date: date,
      weight: _toFiniteDouble(json['weight']) ?? 0,
      calories: _toFiniteDouble(json['calories']) ?? 0,
      protein: _toFiniteDouble(json['protein']) ?? 0,
      carbs: _toFiniteDouble(json['carbs']) ?? 0,
      fats: _toFiniteDouble(json['fats']) ?? 0,
      duration: _toFiniteDouble(json['duration']) ?? 0,
    );
  }

  static List<ProgressPointEntity> listFromResponse(
    Map<String, dynamic> response,
  ) {
    final data = response['data'];
    final list = data is List ? data : const [];
    return list
        .whereType<Map>()
        .map(
          (item) =>
              ProgressPointModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where(
          (point) =>
              point.weight > 0 ||
              point.calories > 0 ||
              point.protein > 0 ||
              point.carbs > 0 ||
              point.fats > 0 ||
              point.duration > 0,
        )
        .toList();
  }
}

class ProgressModel extends ProgressEntity {
  const ProgressModel({
    required super.summary,
    required super.calorieHistory,
    required super.workoutHistory,
  });
}

double? _toFiniteDouble(dynamic value) {
  final parsed = value is num ? value.toDouble() : double.tryParse('$value');
  if (parsed == null || parsed.isNaN || parsed.isInfinite) return null;
  return parsed;
}
