import 'package:nutri_nepal/features/daily_log/domain/entities/daily_log_entity.dart';

class DailyLogModel extends DailyLogEntity {
  const DailyLogModel({
    required super.foodLogs,
    required super.workoutLogs,
    required super.consumedCalories,
    required super.burnedCalories,
    required super.protein,
    required super.carbs,
    required super.fats,
  });

  factory DailyLogModel.fromResponses({
    required Map<String, dynamic> foodResponse,
    required Map<String, dynamic> workoutResponse,
  }) {
    return DailyLogModel(
      foodLogs: _foodLogs(foodResponse['data']),
      workoutLogs: _workoutLogs(workoutResponse['data']),
      consumedCalories: _toDouble(foodResponse['summary']?['calories']),
      burnedCalories: _toDouble(workoutResponse['summary']?['calories']),
      protein: _toDouble(foodResponse['summary']?['protein']),
      carbs: _toDouble(foodResponse['summary']?['carbs']),
      fats: _toDouble(foodResponse['summary']?['fats']),
    );
  }

  static List<DailyLogItemEntity> _foodLogs(dynamic value) {
    final logs = value is List ? value : const [];
    return logs.map((item) {
      final log = Map<String, dynamic>.from(item as Map);
      final food = log['foodId'] is Map
          ? Map<String, dynamic>.from(log['foodId'])
          : {};
      final calories = _toDouble(log['totalCalories']);
      return DailyLogItemEntity(
        id: _idFrom(log['_id']),
        title: (food['name'] ?? 'Unknown Meal').toString(),
        subtitle: '${calories.round()} kcal - ${log['mealType'] ?? 'Meal'}',
        calories: calories,
        raw: log,
      );
    }).toList();
  }

  static List<DailyLogItemEntity> _workoutLogs(dynamic value) {
    final logs = value is List ? value : const [];
    return logs.map((item) {
      final log = Map<String, dynamic>.from(item as Map);
      final workout = log['workoutId'] is Map
          ? Map<String, dynamic>.from(log['workoutId'])
          : {};
      final calories = _toDouble(log['caloriesBurned']);
      final duration = _toDouble(log['duration']);
      return DailyLogItemEntity(
        id: _idFrom(log['_id']),
        title: (workout['name'] ?? 'Unknown Workout').toString(),
        subtitle: '${calories.round()} kcal burned - ${duration.round()} min',
        calories: calories,
        raw: log,
      );
    }).toList();
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static String _idFrom(dynamic value) {
    if (value is Map) return value['\$oid']?.toString() ?? '';
    return value?.toString() ?? '';
  }
}
