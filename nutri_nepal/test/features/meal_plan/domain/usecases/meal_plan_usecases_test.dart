import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutri_nepal/features/meal_plan/domain/entities/meal_plan_entity.dart';
import 'package:nutri_nepal/features/meal_plan/domain/repositories/meal_plan_repository.dart';
import 'package:nutri_nepal/features/meal_plan/domain/usecases/get_food_recommendations_usecase.dart';
import 'package:nutri_nepal/features/meal_plan/domain/usecases/get_meal_plan_usecase.dart';
import 'package:nutri_nepal/features/meal_plan/domain/usecases/log_recommended_food_usecase.dart';

class MockMealPlanRepository extends Mock implements IMealPlanRepository {}

void main() {
  late MockMealPlanRepository repository;

  setUp(() {
    repository = MockMealPlanRepository();
  });

  test('GetFoodRecommendationsUseCase returns foods from repository', () async {
    const foods = [
      FoodItem(
        id: 'food-1',
        name: 'Dal Bhat',
        category: 'Lunch',
        calories: 650,
        protein: 24,
        carbs: 95,
        fats: 18,
        servingSize: 1,
      ),
    ];
    when(() => repository.getFoodRecommendations())
        .thenAnswer((_) async => const Right(foods));

    final result = await GetFoodRecommendationsUseCase(repository)();

    expect(result, const Right(foods));
  });

  test('GetMealPlanUseCase returns planned meals from repository', () async {
    final meals = [
      MealPlanMeal(
        name: 'Oat Meal',
        category: 'Breakfast',
        calories: 320,
        protein: 12,
        carbs: 45,
        date: DateTime(2026, 7, 31),
      ),
    ];
    when(() => repository.getMealPlan()).thenAnswer((_) async => Right(meals));

    final result = await GetMealPlanUseCase(repository)();

    expect(result, Right(meals));
  });

  test('LogRecommendedFoodUseCase passes selected food details', () async {
    final date = DateTime(2026, 7, 31);
    when(
      () => repository.logRecommendedFood(
        foodId: 'food-1',
        mealType: 'Dinner',
        date: date,
      ),
    ).thenAnswer((_) async => const Right<Never, void>(null));

    final result = await LogRecommendedFoodUseCase(repository)(
      LogRecommendedFoodParams(
        foodId: 'food-1',
        mealType: 'Dinner',
        date: date,
      ),
    );

    expect(result, const Right<Never, void>(null));
    verify(
      () => repository.logRecommendedFood(
        foodId: 'food-1',
        mealType: 'Dinner',
        date: date,
      ),
    ).called(1);
  });
}
