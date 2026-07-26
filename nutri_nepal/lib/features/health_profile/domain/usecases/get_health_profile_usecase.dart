import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/health_profile/data/repositories/health_profile_repository_impl.dart';
import 'package:nutri_nepal/features/health_profile/domain/entities/health_profile_entity.dart';
import 'package:nutri_nepal/features/health_profile/domain/repositories/health_profile_repository.dart';

final getHealthProfileUseCaseProvider = Provider<GetHealthProfileUseCase>((ref) {
  return GetHealthProfileUseCase(ref.read(healthProfileRepositoryProvider));
});

class GetHealthProfileUseCase
    implements UsecaseWithoutParams<HealthProfileEntity> {
  final IHealthProfileRepository _repository;

  GetHealthProfileUseCase(this._repository);

  @override
  Future<Either<Failure, HealthProfileEntity>> call() {
    return _repository.getProfile();
  }
}
