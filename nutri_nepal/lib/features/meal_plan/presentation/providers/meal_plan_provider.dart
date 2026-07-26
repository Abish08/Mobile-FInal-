import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/providers/refresh_provider.dart';
import 'package:nutri_nepal/features/meal_plan/domain/entities/meal_plan_entity.dart';
import 'package:nutri_nepal/features/meal_plan/domain/usecases/get_food_recommendations_usecase.dart';
import 'package:nutri_nepal/features/meal_plan/domain/usecases/get_meal_plan_usecase.dart';
import 'package:nutri_nepal/features/meal_plan/domain/usecases/log_recommended_food_usecase.dart';

final mealPlanProvider = AsyncNotifierProvider<MealPlanNotifier, MealPlanState>(
  MealPlanNotifier.new,
);

class MealPlanState extends Equatable {
  final List<FoodItem> foods;
  final List<MealPlanMeal> meals;

  const MealPlanState({required this.foods, required this.meals});
  const MealPlanState.empty() : foods = const [], meals = const [];

  @override
  List<Object?> get props => [foods, meals];
}

class MealPlanNotifier extends AsyncNotifier<MealPlanState> {
  @override
  Future<MealPlanState> build() async => const MealPlanState.empty();

  Future<List<FoodItem>?> loadRecommendations() async {
    final previous = state.asData?.value ?? const MealPlanState.empty();
    state = const AsyncLoading();
    final result = await ref.read(getFoodRecommendationsUseCaseProvider).call();
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (foods) {
        state = AsyncData(MealPlanState(foods: foods, meals: previous.meals));
        return foods;
      },
    );
  }

  Future<List<MealPlanMeal>?> loadMealPlan() async {
    final previous = state.asData?.value ?? const MealPlanState.empty();
    state = const AsyncLoading();
    final result = await ref.read(getMealPlanUseCaseProvider).call();
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (meals) {
        state = AsyncData(MealPlanState(foods: previous.foods, meals: meals));
        return meals;
      },
    );
  }

  List<FoodItem> filterFoods(List<FoodItem> foods, String mealType) {
    if (mealType == 'All') return foods;
    final selected = mealType.toLowerCase();
    return foods.where((food) {
      final category = food.category.toLowerCase();
      return category.contains(selected) ||
          (selected == 'snacks' && category.contains('snack'));
    }).toList();
  }

  Future<bool> logRecommendedFood(
    FoodItem food,
    String selectedMealType,
  ) async {
    var mealType = selectedMealType == 'Snacks' ? 'Snack' : selectedMealType;
    if (mealType == 'All') mealType = 'Snack';

    final result = await ref
        .read(logRecommendedFoodUseCaseProvider)
        .call(
          LogRecommendedFoodParams(
            foodId: food.id,
            mealType: mealType,
            date: DateTime.now(),
          ),
        );

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref.invalidateSelf();
        ref.read(refreshProvider.notifier).refresh();
        return true;
      },
    );
  }

  Future<List<FoodItem>?> retryRecommendations() => loadRecommendations();
  Future<List<MealPlanMeal>?> retryMealPlan() => loadMealPlan();
}
