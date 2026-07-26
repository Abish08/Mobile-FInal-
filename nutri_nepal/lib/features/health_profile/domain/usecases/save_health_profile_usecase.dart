import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/health_profile/data/repositories/health_profile_repository_impl.dart';
import 'package:nutri_nepal/features/health_profile/domain/entities/health_profile_entity.dart';
import 'package:nutri_nepal/features/health_profile/domain/repositories/health_profile_repository.dart';

final saveHealthProfileUseCaseProvider = Provider<SaveHealthProfileUseCase>((ref) {
  return SaveHealthProfileUseCase(ref.read(healthProfileRepositoryProvider));
});

class SaveHealthProfileUseCase
    implements UsecaseWithParams<HealthProfileEntity, HealthProfileEntity> {
  final IHealthProfileRepository _repository;

  SaveHealthProfileUseCase(this._repository);

  @override
  Future<Either<Failure, HealthProfileEntity>> call(
    HealthProfileEntity params,
  ) {
    return _repository.saveProfile(params);
  }
}
