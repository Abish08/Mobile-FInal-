import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/daily_log/data/datasources/daily_log_remote_datasource.dart';
import 'package:nutri_nepal/features/daily_log/domain/entities/daily_log_entity.dart';
import 'package:nutri_nepal/features/daily_log/domain/repositories/daily_log_repository.dart';

final dailyLogRepositoryProvider = Provider<IDailyLogRepository>((ref) {
  return DailyLogRepositoryImpl(ref.read(dailyLogRemoteDataSourceProvider));
});

class DailyLogRepositoryImpl implements IDailyLogRepository {
  final DailyLogRemoteDataSource _remoteDataSource;

  DailyLogRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, DailyLogEntity>> getDailyLog(DateTime date) async {
    try {
      return Right(await _remoteDataSource.getDailyLog(date));
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLog({
    required String id,
    required bool isWorkout,
  }) async {
    try {
      await _remoteDataSource.deleteLog(id: id, isWorkout: isWorkout);
      return const Right(null);
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}
