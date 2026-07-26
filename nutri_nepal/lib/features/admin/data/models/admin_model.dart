import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/admin/domain/entities/admin_entity.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';

class AdminModel {
  AdminModel._();

  static AdminDashboardStats dashboardStats({
    required dynamic userStatsResponse,
    required dynamic foodStatsResponse,
    required dynamic workoutsResponse,
  }) {
    final stats = userStatsResponse is Map
        ? userStatsResponse['stats'] ?? const {}
        : const {};
    final foodStats = foodStatsResponse is Map
        ? foodStatsResponse['stats'] ?? const {}
        : const {};
    final workouts =
        workoutsResponse is Map && workoutsResponse['workouts'] is List
        ? workoutsResponse['workouts'] as List
        : const [];

    return AdminDashboardStats(
      totalUsers: _int(stats['totalUsers']),
      totalFoodItems: _int(foodStats['totalItems']),
      totalWorkouts: workouts.length,
      activeToday: _int(stats['newToday']),
      fitnessGoals: _fitnessGoals(stats['usersByGoal']),
      bmiDistribution: _bmiDistribution(stats['bmiDistribution']),
    );
  }

  static AdminUserList userList(dynamic responseData) {
    final data = responseData is Map ? responseData : const {};
    final usersData = data['users'] is List ? data['users'] as List : const [];
    final users = usersData
        .whereType<Map>()
        .map((user) => AuthEntity.fromJson(Map<String, dynamic>.from(user)))
        .toList();

    return AdminUserList(
      users: users,
      totalUsers: _int(data['totalUsers'], fallback: users.length),
      newToday: _int(data['newToday']),
    );
  }

  static AdminFoodList foodList({
    required dynamic foodsResponse,
    required dynamic statsResponse,
  }) {
    final foodsData = foodsResponse is Map && foodsResponse['foods'] is List
        ? foodsResponse['foods'] as List
        : const [];
    final stats = statsResponse is Map
        ? statsResponse['stats'] ?? const {}
        : const {};
    return AdminFoodList(
      foods: foodsData
          .whereType<Map>()
          .map(
            (food) => AdminFoodModel.fromJson(Map<String, dynamic>.from(food)),
          )
          .toList(),
      totalItems: _int(stats['totalItems'], fallback: foodsData.length),
      pendingApproval: _int(stats['pendingApproval']),
    );
  }

  static List<AdminWorkout> workoutList(dynamic responseData) {
    final workoutsData = responseData is Map && responseData['workouts'] is List
        ? responseData['workouts'] as List
        : const [];
    return workoutsData
        .whereType<Map>()
        .map(
          (workout) =>
              AdminWorkoutModel.fromJson(Map<String, dynamic>.from(workout)),
        )
        .toList();
  }

  static Map<String, int> _fitnessGoals(dynamic value) {
    final result = {
      'Weight Loss': 0,
      'Muscle Gain': 0,
      'Endurance': 0,
      'Maintenance': 0,
    };
    if (value is! List) return result;
    for (final item in value.whereType<Map>()) {
      var goalName = (item['_id'] ?? 'Unknown').toString();
      final normalized = goalName.toLowerCase();
      if (normalized.contains('weight') || normalized.contains('loss')) {
        goalName = 'Weight Loss';
      } else if (normalized.contains('muscle') || normalized.contains('gain')) {
        goalName = 'Muscle Gain';
      } else if (normalized.contains('endurance')) {
        goalName = 'Endurance';
      } else if (normalized.contains('maintain') ||
          normalized.contains('maintenance')) {
        goalName = 'Maintenance';
      }
      result[goalName] = (result[goalName] ?? 0) + _int(item['count']);
    }
    return result;
  }

  static Map<String, int> _bmiDistribution(dynamic value) {
    final result = {'underweight': 0, 'normal': 0, 'overweight': 0, 'obese': 0};
    if (value is! List) return result;
    for (final item in value.whereType<Map>()) {
      final category = (item['_id'] ?? '').toString().toLowerCase();
      final count = _int(item['count']);
      if (category.contains('under')) {
        result['underweight'] = result['underweight']! + count;
      } else if (category.contains('normal')) {
        result['normal'] = result['normal']! + count;
      } else if (category.contains('over')) {
        result['overweight'] = result['overweight']! + count;
      } else if (category.contains('obese')) {
        result['obese'] = result['obese']! + count;
      }
    }
    return result;
  }
}

class AdminFoodModel extends AdminFood {
  const AdminFoodModel({
    required super.id,
    required super.name,
    required super.category,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fats,
    super.fiber,
    super.sugar,
    super.sodium,
    required super.servingSize,
    super.description,
    super.isApproved,
    super.status,
    super.thumbnail,
    super.thumbnailUrl,
    super.images,
  });

  factory AdminFoodModel.fromJson(Map<String, dynamic> json) {
    final thumbnail = _thumbnail(json);
    return AdminFoodModel(
      id: _id(json['_id']),
      name: _text(json['name'] ?? json['mealName'], fallback: 'Unknown'),
      category: _text(json['category'], fallback: 'General'),
      calories: _int(json['calories']),
      protein: _double(json['protein']),
      carbs: _double(json['carbs']),
      fats: _double(json['fats']),
      fiber: _double(json['fiber']),
      sugar: _double(json['sugar']),
      sodium: _double(json['sodium']),
      servingSize: '${json['servingSize'] ?? 100}g',
      description: _text(json['description']),
      isApproved: json['isApproved'] != false,
      status: json['isApproved'] == false ? 'pending' : 'approved',
      thumbnail: thumbnail,
      thumbnailUrl: thumbnail == null
          ? null
          : ApiEndpoints.resolveUploadUrl(thumbnail),
      images: json['images'] is List
          ? List<String>.from(json['images'])
          : const [],
    );
  }

  static Map<String, dynamic> inputToJson(AdminFoodInput input) {
    return {
      'name': input.name,
      'category': input.category,
      'servingSize': input.servingSize,
      'calories': input.calories,
      'protein': input.protein,
      'carbs': input.carbs,
      'fats': input.fats,
      'fiber': input.fiber,
      'sugar': input.sugar,
      'sodium': input.sodium,
      'description': input.description,
      'isApproved': input.isApproved,
    };
  }
}

class AdminWorkoutModel extends AdminWorkout {
  const AdminWorkoutModel({
    required super.id,
    required super.name,
    required super.category,
    required super.day,
    super.difficulty,
    super.duration,
    super.caloriesBurned,
    super.equipment,
    super.thumbnail,
    super.thumbnailUrl,
    super.youtubeUrl,
    super.sets,
    super.reps,
    super.rest,
    super.intensity,
    super.cycles,
    super.focus,
    super.description,
  });

  factory AdminWorkoutModel.fromJson(Map<String, dynamic> json) {
    final thumbnail = _thumbnail(json);
    return AdminWorkoutModel(
      id: _id(json['_id']),
      name: _text(json['name'], fallback: 'Unknown'),
      category: _text(json['category'], fallback: 'Other'),
      day: _text(json['day'], fallback: 'Any Day'),
      difficulty: _text(json['difficulty']),
      duration: _text(json['duration']),
      caloriesBurned: _nullableInt(json['caloriesBurned']),
      equipment: _text(json['equipment']),
      thumbnail: thumbnail,
      thumbnailUrl: thumbnail == null
          ? null
          : ApiEndpoints.resolveUploadUrl(thumbnail),
      youtubeUrl: _text(json['youtubeUrl']),
      sets: _nullableInt(json['sets']),
      reps: _nullableInt(json['reps']),
      rest: _text(json['rest']),
      intensity: _text(json['intensity']),
      cycles: _nullableInt(json['cycles']),
      focus: _text(json['focus']),
      description: _text(json['description']),
    );
  }

  static Map<String, dynamic> inputToJson(AdminWorkoutInput input) {
    return {
      'name': input.name,
      'category': input.category,
      'day': input.day,
      'sets': input.sets,
      'reps': input.reps,
      'rest': input.rest,
      'duration': input.duration,
      'intensity': input.intensity,
      'cycles': input.cycles,
      'focus': input.focus,
      'description': input.description,
      'youtubeUrl': input.youtubeUrl,
    };
  }
}

String _id(dynamic value) {
  if (value is Map) return value['\$oid']?.toString() ?? '';
  return value?.toString() ?? '';
}

String _text(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

int _int(dynamic value, {int fallback = 0}) {
  final parsed = value is num ? value.toInt() : int.tryParse('$value');
  return parsed ?? fallback;
}

int? _nullableInt(dynamic value) {
  final parsed = value is num ? value.toInt() : int.tryParse('$value');
  return parsed;
}

double _double(dynamic value) {
  final parsed = value is num ? value.toDouble() : double.tryParse('$value');
  if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed < 0) {
    return 0;
  }
  return parsed;
}

String? _thumbnail(Map<String, dynamic> json) {
  final thumbnail = json['thumbnail'];
  if (thumbnail is String && thumbnail.isNotEmpty) return thumbnail;
  if (thumbnail is Map && thumbnail['url'] != null) {
    return thumbnail['url'].toString();
  }
  final images = json['images'];
  if (images is List && images.isNotEmpty) {
    final first = images.first;
    if (first is String) return first;
    if (first is Map && first['url'] != null) return first['url'].toString();
  }
  return null;
}
