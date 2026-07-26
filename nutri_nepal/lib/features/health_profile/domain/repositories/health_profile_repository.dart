import 'package:dartz/dartz.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/health_profile/domain/entities/health_profile_entity.dart';

abstract class IHealthProfileRepository {
  Future<Either<Failure, HealthProfileEntity>> getProfile();
  Future<Either<Failure, HealthProfileEntity>> saveProfile(
    HealthProfileEntity profile,
  );
}
