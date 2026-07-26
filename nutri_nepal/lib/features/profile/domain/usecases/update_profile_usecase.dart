import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:nutri_nepal/features/profile/domain/entities/profile_entity.dart';
import 'package:nutri_nepal/features/profile/domain/repositories/profile_repository.dart';

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.read(profileRepositoryProvider));
});

class UpdateProfileUseCase {
  final IProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, ProfileEntity>> call(ProfileEntity profile) {
    return _repository.updateProfile(profile);
  }
}
