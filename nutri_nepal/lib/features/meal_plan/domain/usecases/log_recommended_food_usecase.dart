import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/meal_plan/data/repositories/meal_plan_repository_impl.dart';
import 'package:nutri_nepal/features/meal_plan/domain/repositories/meal_plan_repository.dart';

final logRecommendedFoodUseCaseProvider = Provider<LogRecommendedFoodUseCase>((
  ref,
) {
  return LogRecommendedFoodUseCase(ref.read(mealPlanRepositoryProvider));
});

class LogRecommendedFoodParams {
  final String foodId;
  final String mealType;
  final DateTime date;

  const LogRecommendedFoodParams({
    required this.foodId,
    required this.mealType,
    required this.date,
  });
}

class LogRecommendedFoodUseCase
    implements UsecaseWithParams<void, LogRecommendedFoodParams> {
  final IMealPlanRepository _repository;

  LogRecommendedFoodUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(LogRecommendedFoodParams params) {
    return _repository.logRecommendedFood(
      foodId: params.foodId,
      mealType: params.mealType,
      date: params.date,
    );
  }
}
