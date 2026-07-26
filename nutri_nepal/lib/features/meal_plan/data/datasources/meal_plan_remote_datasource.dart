import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/meal_plan/data/models/meal_plan_model.dart';
import 'package:nutri_nepal/features/meal_plan/domain/entities/meal_plan_entity.dart';

final mealPlanRemoteDataSourceProvider = Provider<MealPlanRemoteDataSource>((
  ref,
) {
  return MealPlanRemoteDataSourceImpl(ApiClient());
});

abstract class MealPlanRemoteDataSource {
  Future<List<FoodItem>> getFoodRecommendations();
  Future<List<MealPlanMeal>> getMealPlan();
  Future<void> logRecommendedFood({
    required String foodId,
    required String mealType,
    required DateTime date,
  });
}

class MealPlanRemoteDataSourceImpl implements MealPlanRemoteDataSource {
  final ApiClient _apiClient;

  MealPlanRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<FoodItem>> getFoodRecommendations() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.publicFoods);
      return FoodItemModel.listFromResponse(response.data);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to load food recommendations'));
    }
  }

  @override
  Future<List<MealPlanMeal>> getMealPlan() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.meals);
      return MealPlanMealModel.listFromResponse(response.data);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to load meal plan'));
    }
  }

  @override
  Future<void> logRecommendedFood({
    required String foodId,
    required String mealType,
    required DateTime date,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.foodLogs,
        data: {
          'foodId': foodId,
          'servings': 1,
          'mealType': mealType,
          'date': date.toIso8601String().split('T')[0],
        },
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to log meal'));
    }
  }

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return fallback;
  }
}
