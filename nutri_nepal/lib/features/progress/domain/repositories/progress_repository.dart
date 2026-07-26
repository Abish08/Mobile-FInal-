import 'package:dartz/dartz.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/progress/domain/entities/progress_entity.dart';

abstract class IProgressRepository {
  Future<Either<Failure, ProgressSummaryEntity>> getSummary();
  Future<Either<Failure, List<ProgressPointEntity>>> getCalorieHistory({
    int days = 30,
  });
  Future<Either<Failure, List<ProgressPointEntity>>> getWorkoutHistory({
    int days = 30,
  });
  Future<Either<Failure, void>> addProgress({required double weight});
}
