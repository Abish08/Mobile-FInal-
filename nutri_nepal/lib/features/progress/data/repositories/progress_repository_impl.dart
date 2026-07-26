import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/progress/data/datasources/progress_remote_datasource.dart';
import 'package:nutri_nepal/features/progress/domain/entities/progress_entity.dart';
import 'package:nutri_nepal/features/progress/domain/repositories/progress_repository.dart';

final progressRepositoryProvider = Provider<IProgressRepository>((ref) {
  return ProgressRepositoryImpl(ref.read(progressRemoteDataSourceProvider));
});

class ProgressRepositoryImpl implements IProgressRepository {
  final ProgressRemoteDataSource _remoteDataSource;

  ProgressRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ProgressSummaryEntity>> getSummary() async {
    try {
      return Right(await _remoteDataSource.getSummary());
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProgressPointEntity>>> getCalorieHistory({
    int days = 30,
  }) async {
    try {
      return Right(await _remoteDataSource.getCalorieHistory(days: days));
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProgressPointEntity>>> getWorkoutHistory({
    int days = 30,
  }) async {
    try {
      return Right(await _remoteDataSource.getWorkoutHistory(days: days));
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProgress({required double weight}) async {
    try {
      await _remoteDataSource.addProgress(weight: weight);
      return const Right(null);
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}
