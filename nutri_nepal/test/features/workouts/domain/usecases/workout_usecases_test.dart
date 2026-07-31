import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutri_nepal/features/workouts/domain/entities/workout_entity.dart';
import 'package:nutri_nepal/features/workouts/domain/repositories/workout_repository.dart';
import 'package:nutri_nepal/features/workouts/domain/usecases/get_workouts_usecase.dart';
import 'package:nutri_nepal/features/workouts/domain/usecases/log_workout_usecase.dart';

class MockWorkoutRepository extends Mock implements IWorkoutRepository {}

void main() {
  late MockWorkoutRepository repository;

  setUp(() {
    repository = MockWorkoutRepository();
  });

  test('GetWorkoutsUseCase returns workout catalog', () async {
    const workouts = [
      UserWorkout(
        id: 'workout-1',
        name: 'Bench Press',
        category: 'Strength',
        thumbnail: 'http://localhost/uploads/workout.jpg',
      ),
    ];
    when(() => repository.getWorkouts())
        .thenAnswer((_) async => const Right(workouts));

    final result = await GetWorkoutsUseCase(repository)();

    expect(result, const Right(workouts));
  });

  test('LogWorkoutUseCase passes workout log payload', () async {
    final date = DateTime(2026, 7, 31);
    when(
      () => repository.logWorkout(
        workoutId: 'workout-1',
        duration: 45,
        date: date,
      ),
    ).thenAnswer((_) async => const Right<Never, void>(null));

    final result = await LogWorkoutUseCase(repository)(
      LogWorkoutParams(workoutId: 'workout-1', duration: 45, date: date),
    );

    expect(result, const Right<Never, void>(null));
    verify(
      () => repository.logWorkout(
        workoutId: 'workout-1',
        duration: 45,
        date: date,
      ),
    ).called(1);
  });
}
