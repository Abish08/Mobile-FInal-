import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/workouts/data/repositories/workout_repository_impl.dart';
import 'package:nutri_nepal/features/workouts/domain/repositories/workout_repository.dart';

final logWorkoutUseCaseProvider = Provider<LogWorkoutUseCase>((ref) {
  return LogWorkoutUseCase(ref.read(workoutRepositoryProvider));
});

class LogWorkoutParams {
  final String workoutId;
  final int duration;
  final DateTime date;

  const LogWorkoutParams({
    required this.workoutId,
    required this.duration,
    required this.date,
  });
}

class LogWorkoutUseCase implements UsecaseWithParams<void, LogWorkoutParams> {
  final IWorkoutRepository _repository;

  LogWorkoutUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(LogWorkoutParams params) {
    return _repository.logWorkout(
      workoutId: params.workoutId,
      duration: params.duration,
      date: params.date,
    );
  }
}
