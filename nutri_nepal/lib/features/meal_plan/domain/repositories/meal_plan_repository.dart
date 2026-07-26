import 'package:dartz/dartz.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/meal_plan/domain/entities/meal_plan_entity.dart';

abstract class IMealPlanRepository {
  Future<Either<Failure, List<FoodItem>>> getFoodRecommendations();
  Future<Either<Failure, List<MealPlanMeal>>> getMealPlan();
  Future<Either<Failure, void>> logRecommendedFood({
    required String foodId,
    required String mealType,
    required DateTime date,
  });
}
