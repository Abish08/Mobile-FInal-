import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:nutri_nepal/features/auth/domain/repositories/auth_repository.dart';

final googleLoginUseCaseProvider = Provider<GoogleLoginUseCase>((ref) {
  return GoogleLoginUseCase(ref.read(authRepositoryProvider));
});

class GoogleLoginUseCase {
  final IAuthRepository _authRepository;

  GoogleLoginUseCase(this._authRepository);

  Future<Either<Failure, AuthEntity>> call(String idToken) {
    return _authRepository.loginWithGoogle(idToken);
  }
}
