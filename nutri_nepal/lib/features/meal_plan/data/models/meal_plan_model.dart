import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/meal_plan/domain/entities/meal_plan_entity.dart';

class FoodItemModel extends FoodItem {
  const FoodItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fats,
    required super.servingSize,
    super.thumbnail,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    final thumbnail = _thumbnailFrom(json);
    return FoodItemModel(
      id: _idFrom(json['_id']),
      name: _text(json['name'], fallback: 'Unknown'),
      category: _text(json['category'], fallback: 'General'),
      calories: _nonNegativeInt(json['calories']),
      protein: _finiteDouble(json['protein']) ?? 0,
      carbs: _finiteDouble(json['carbs']) ?? 0,
      fats: _finiteDouble(json['fats']) ?? 0,
      servingSize: _finiteDouble(json['servingSize']) ?? 1,
      thumbnail: thumbnail == null
          ? null
          : ApiEndpoints.resolveUploadUrl(thumbnail, defaultFolder: 'foods'),
    );
  }

  static List<FoodItem> listFromResponse(dynamic responseData) {
    List<dynamic> raw = const [];
    if (responseData is Map) {
      raw =
          (responseData['foods'] ?? responseData['data'] ?? [])
              as List<dynamic>;
    } else if (responseData is List) {
      raw = responseData;
    }
    return raw
        .whereType<Map>()
        .map((item) => FoodItemModel.fromJson(Map<String, dynamic>.from(item)))
        .where((food) => food.id.isNotEmpty)
        .toList();
  }
}

class MealPlanMealModel extends MealPlanMeal {
  const MealPlanMealModel({
    required super.name,
    required super.category,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.date,
  });

  factory MealPlanMealModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'] ?? json['date'];
    return MealPlanMealModel(
      name: _text(json['name'], fallback: 'Unknown Meal'),
      category: _text(json['category'], fallback: 'Meal'),
      calories: _nonNegativeInt(json['calories']),
      protein: _nonNegativeInt(json['protein']),
      carbs: _nonNegativeInt(json['carbs']),
      date: rawDate == null ? null : DateTime.tryParse(rawDate.toString()),
    );
  }

  static List<MealPlanMeal> listFromResponse(dynamic responseData) {
    final data = responseData is Map
        ? responseData['data'] ?? []
        : responseData;
    final raw = data is List ? data : const [];
    return raw
        .whereType<Map>()
        .map(
          (item) => MealPlanMealModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}

String _idFrom(dynamic value) {
  if (value is Map) return value['\$oid']?.toString() ?? '';
  return value?.toString() ?? '';
}

String _text(dynamic value, {required String fallback}) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

double? _finiteDouble(dynamic value) {
  final parsed = value is num ? value.toDouble() : double.tryParse('$value');
  if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed < 0) {
    return null;
  }
  return parsed;
}

int _nonNegativeInt(dynamic value) {
  final parsed = _finiteDouble(value);
  if (parsed == null) {
    return 0;
  }
  return parsed.round();
}

String? _thumbnailFrom(Map<String, dynamic> json) {
  final thumbnail = json['thumbnail'];
  if (thumbnail is String && thumbnail.trim().isNotEmpty) {
    return thumbnail;
  }
  if (thumbnail is Map && thumbnail['url'] != null) {
    return thumbnail['url'].toString();
  }
  final images = json['images'];
  if (images is List && images.isNotEmpty) {
    final first = images.first;
    if (first is String) {
      return first;
    }
    if (first is Map && first['url'] != null) {
      return first['url'].toString();
    }
  }
  return null;
}
