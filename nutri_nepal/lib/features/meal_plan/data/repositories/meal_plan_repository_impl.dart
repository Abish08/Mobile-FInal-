import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/meal_plan/data/datasources/meal_plan_remote_datasource.dart';
import 'package:nutri_nepal/features/meal_plan/domain/entities/meal_plan_entity.dart';
import 'package:nutri_nepal/features/meal_plan/domain/repositories/meal_plan_repository.dart';

final mealPlanRepositoryProvider = Provider<IMealPlanRepository>((ref) {
  return MealPlanRepositoryImpl(ref.read(mealPlanRemoteDataSourceProvider));
});

class MealPlanRepositoryImpl implements IMealPlanRepository {
  final MealPlanRemoteDataSource _remoteDataSource;

  MealPlanRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<FoodItem>>> getFoodRecommendations() async {
    try {
      return Right(await _remoteDataSource.getFoodRecommendations());
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealPlanMeal>>> getMealPlan() async {
    try {
      return Right(await _remoteDataSource.getMealPlan());
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logRecommendedFood({
    required String foodId,
    required String mealType,
    required DateTime date,
  }) async {
    try {
      await _remoteDataSource.logRecommendedFood(
        foodId: foodId,
        mealType: mealType,
        date: date,
      );
      return const Right(null);
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}
