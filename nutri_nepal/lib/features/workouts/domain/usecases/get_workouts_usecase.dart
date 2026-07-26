import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/workouts/data/repositories/workout_repository_impl.dart';
import 'package:nutri_nepal/features/workouts/domain/entities/workout_entity.dart';
import 'package:nutri_nepal/features/workouts/domain/repositories/workout_repository.dart';

final getWorkoutsUseCaseProvider = Provider<GetWorkoutsUseCase>((ref) {
  return GetWorkoutsUseCase(ref.read(workoutRepositoryProvider));
});

class GetWorkoutsUseCase implements UsecaseWithoutParams<List<UserWorkout>> {
  final IWorkoutRepository _repository;

  GetWorkoutsUseCase(this._repository);

  @override
  Future<Either<Failure, List<UserWorkout>>> call() {
    return _repository.getWorkouts();
  }
}
