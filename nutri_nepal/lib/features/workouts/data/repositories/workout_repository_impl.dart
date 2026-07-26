import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/workouts/data/datasources/workout_remote_datasource.dart';
import 'package:nutri_nepal/features/workouts/domain/entities/workout_entity.dart';
import 'package:nutri_nepal/features/workouts/domain/repositories/workout_repository.dart';

final workoutRepositoryProvider = Provider<IWorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(ref.read(workoutRemoteDataSourceProvider));
});

class WorkoutRepositoryImpl implements IWorkoutRepository {
  final WorkoutRemoteDataSource _remoteDataSource;

  WorkoutRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<UserWorkout>>> getWorkouts() async {
    try {
      return Right(await _remoteDataSource.getWorkouts());
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logWorkout({
    required String workoutId,
    required int duration,
    required DateTime date,
  }) async {
    try {
      await _remoteDataSource.logWorkout(
        workoutId: workoutId,
        duration: duration,
        date: date,
      );
      return const Right(null);
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}
