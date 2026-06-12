import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/auth/data/datasources/auth_datasource.dart'; // ← Interface
import 'package:nutri_nepal/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:nutri_nepal/features/auth/data/datasources/remote/auth_datasource.dart'; // ← Remote
import 'package:nutri_nepal/features/auth/data/models/auth_hive_model.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:nutri_nepal/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authLocalDatasourceProvider),
    ref.read(authRemoteDataSourceProvider),
  );
});

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDatasource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final registeredUser = await _remoteDataSource.register(model);
      await _localDataSource.register(registeredUser);
      return const Right(true);
    } catch (error) {
      return Left(LocalDatabaseFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final loggedInUser = await _remoteDataSource.login(email, password);
      await _localDataSource.register(loggedInUser);
      return Right(loggedInUser.toEntity());
    } catch (error) {
      return Left(LocalDatabaseFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      await _localDataSource.register(user);
      return Right(user.toEntity());
    } catch (error) {
      try {
        final localUser = await _localDataSource.getCurrentUser();
        if (localUser == null) {
          return const Left(LocalDatabaseFailure(message: 'No active session.'));
        }
        return Right(localUser.toEntity());
      } catch (localError) {
        return Left(LocalDatabaseFailure(message: localError.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.logout();
      return const Right(true);
    } catch (error) {
      return Left(LocalDatabaseFailure(message: error.toString()));
    }
  }
}