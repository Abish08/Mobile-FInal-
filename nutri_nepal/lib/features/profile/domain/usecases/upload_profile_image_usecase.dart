import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:nutri_nepal/features/profile/domain/entities/profile_entity.dart';
import 'package:nutri_nepal/features/profile/domain/repositories/profile_repository.dart';

final uploadProfileImageUseCaseProvider = Provider<UploadProfileImageUseCase>((
  ref,
) {
  return UploadProfileImageUseCase(ref.read(profileRepositoryProvider));
});

class UploadProfileImageUseCase {
  final IProfileRepository _repository;

  UploadProfileImageUseCase(this._repository);

  Future<Either<Failure, ProfileEntity>> call(File imageFile) {
    return _repository.uploadProfileImage(imageFile);
  }
}
