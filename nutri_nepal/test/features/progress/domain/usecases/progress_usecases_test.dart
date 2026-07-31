import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutri_nepal/features/progress/domain/entities/progress_entity.dart';
import 'package:nutri_nepal/features/progress/domain/repositories/progress_repository.dart';
import 'package:nutri_nepal/features/progress/domain/usecases/add_progress_usecase.dart';
import 'package:nutri_nepal/features/progress/domain/usecases/get_calorie_history_usecase.dart';
import 'package:nutri_nepal/features/progress/domain/usecases/get_progress_summary_usecase.dart';
import 'package:nutri_nepal/features/progress/domain/usecases/get_workout_history_usecase.dart';

class MockProgressRepository extends Mock implements IProgressRepository {}

void main() {
  late MockProgressRepository repository;

  setUp(() {
    repository = MockProgressRepository();
  });

  test('GetProgressSummaryUseCase returns summary', () async {
    const summary = ProgressSummaryEntity(startWeight: 72, currentWeight: 70);
    when(() => repository.getSummary())
        .thenAnswer((_) async => const Right(summary));

    final result = await GetProgressSummaryUseCase(repository)();

    expect(result, const Right(summary));
  });

  test('history use cases pass requested day count', () async {
    const points = [
      ProgressPointEntity(
        label: 'Jul 31',
        date: null,
        weight: 70,
        calories: 2100,
      ),
    ];
    when(() => repository.getCalorieHistory(days: 14))
        .thenAnswer((_) async => const Right(points));
    when(() => repository.getWorkoutHistory(days: 14))
        .thenAnswer((_) async => const Right(points));

    expect(await GetCalorieHistoryUseCase(repository)(14), const Right(points));
    expect(await GetWorkoutHistoryUseCase(repository)(14), const Right(points));
  });

  test('AddProgressUseCase passes weight', () async {
    when(() => repository.addProgress(weight: 69.5))
        .thenAnswer((_) async => const Right<Never, void>(null));

    final result = await AddProgressUseCase(repository)(69.5);

    expect(result, const Right<Never, void>(null));
    verify(() => repository.addProgress(weight: 69.5)).called(1);
  });
}
