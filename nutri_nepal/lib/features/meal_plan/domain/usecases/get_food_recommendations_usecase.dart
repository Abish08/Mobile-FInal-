import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/meal_plan/data/repositories/meal_plan_repository_impl.dart';
import 'package:nutri_nepal/features/meal_plan/domain/entities/meal_plan_entity.dart';
import 'package:nutri_nepal/features/meal_plan/domain/repositories/meal_plan_repository.dart';

final getFoodRecommendationsUseCaseProvider =
    Provider<GetFoodRecommendationsUseCase>((ref) {
      return GetFoodRecommendationsUseCase(
        ref.read(mealPlanRepositoryProvider),
      );
    });

class GetFoodRecommendationsUseCase
    implements UsecaseWithoutParams<List<FoodItem>> {
  final IMealPlanRepository _repository;

  GetFoodRecommendationsUseCase(this._repository);

  @override
  Future<Either<Failure, List<FoodItem>>> call() {
    return _repository.getFoodRecommendations();
  }
}
