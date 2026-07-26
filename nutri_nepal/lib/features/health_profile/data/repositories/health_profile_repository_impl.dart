import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/health_profile/data/datasources/health_profile_remote_datasource.dart';
import 'package:nutri_nepal/features/health_profile/data/models/health_profile_model.dart';
import 'package:nutri_nepal/features/health_profile/domain/entities/health_profile_entity.dart';
import 'package:nutri_nepal/features/health_profile/domain/repositories/health_profile_repository.dart';

final healthProfileRepositoryProvider = Provider<IHealthProfileRepository>((ref) {
  return HealthProfileRepositoryImpl(
    ref.read(healthProfileRemoteDataSourceProvider),
  );
});

class HealthProfileRepositoryImpl implements IHealthProfileRepository {
  final HealthProfileRemoteDataSource _remoteDataSource;

  HealthProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, HealthProfileEntity>> getProfile() async {
    try {
      return Right(await _remoteDataSource.getProfile());
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, HealthProfileEntity>> saveProfile(
    HealthProfileEntity profile,
  ) async {
    try {
      final model = HealthProfileModel.fromEntity(profile);
      return Right(await _remoteDataSource.saveProfile(model));
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}
