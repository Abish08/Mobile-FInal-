import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/core/usecases/app_usecase.dart';
import 'package:nutri_nepal/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:nutri_nepal/features/profile/domain/entities/profile_entity.dart';
import 'package:nutri_nepal/features/profile/domain/repositories/profile_repository.dart';

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.read(profileRepositoryProvider));
});

class GetProfileUseCase implements UsecaseWithoutParams<ProfileEntity> {
  final IProfileRepository _repository;

  GetProfileUseCase(this._repository);

  @override
  Future<Either<Failure, ProfileEntity>> call() => _repository.getProfile();
}
