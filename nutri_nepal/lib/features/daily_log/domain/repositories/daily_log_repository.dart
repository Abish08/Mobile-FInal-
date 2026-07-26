import 'package:dartz/dartz.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/daily_log/domain/entities/daily_log_entity.dart';

abstract class IDailyLogRepository {
  Future<Either<Failure, DailyLogEntity>> getDailyLog(DateTime date);
  Future<Either<Failure, void>> deleteLog({
    required String id,
    required bool isWorkout,
  });
}
