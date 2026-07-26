import 'package:dartz/dartz.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/workouts/domain/entities/workout_entity.dart';

abstract class IWorkoutRepository {
  Future<Either<Failure, List<UserWorkout>>> getWorkouts();
  Future<Either<Failure, void>> logWorkout({
    required String workoutId,
    required int duration,
    required DateTime date,
  });
}
