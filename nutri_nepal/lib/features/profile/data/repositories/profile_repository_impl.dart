import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:nutri_nepal/features/profile/data/models/profile_model.dart';
import 'package:nutri_nepal/features/profile/domain/entities/profile_entity.dart';
import 'package:nutri_nepal/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.read(profileRemoteDataSourceProvider));
});

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      return Right(await _remoteDataSource.getProfile());
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
    ProfileEntity profile,
  ) async {
    try {
      return Right(
        await _remoteDataSource.updateProfile(ProfileModel.fromEntity(profile)),
      );
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> uploadProfileImage(
    File imageFile,
  ) async {
    try {
      return Right(await _remoteDataSource.uploadProfileImage(imageFile));
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}
