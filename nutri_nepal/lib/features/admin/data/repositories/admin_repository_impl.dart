import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:nutri_nepal/features/admin/domain/entities/admin_entity.dart';
import 'package:nutri_nepal/features/admin/domain/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<IAdminRepository>((ref) {
  return AdminRepositoryImpl(ref.read(adminRemoteDataSourceProvider));
});

class AdminRepositoryImpl implements IAdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, AdminDashboardStats>> getDashboardStats() async =>
      _guard(_remoteDataSource.getDashboardStats);

  @override
  Future<Either<Failure, AdminUserList>> getUsers({
    required String search,
    required String goal,
  }) async =>
      _guard(() => _remoteDataSource.getUsers(search: search, goal: goal));

  @override
  Future<Either<Failure, void>> deleteUser(String id) async =>
      _guard(() => _remoteDataSource.deleteUser(id));

  @override
  Future<Either<Failure, AdminFoodList>> getFoods({
    required String search,
    required String category,
  }) async => _guard(
    () => _remoteDataSource.getFoods(search: search, category: category),
  );

  @override
  Future<Either<Failure, String>> saveFood(AdminFoodInput input) async =>
      _guard(() => _remoteDataSource.saveFood(input));

  @override
  Future<Either<Failure, void>> deleteFood(String id) async =>
      _guard(() => _remoteDataSource.deleteFood(id));

  @override
  Future<Either<Failure, List<AdminWorkout>>> getWorkouts({
    required String category,
  }) async => _guard(() => _remoteDataSource.getWorkouts(category: category));

  @override
  Future<Either<Failure, String>> saveWorkout(AdminWorkoutInput input) async =>
      _guard(() => _remoteDataSource.saveWorkout(input));

  @override
  Future<Either<Failure, void>> deleteWorkout(String id) async =>
      _guard(() => _remoteDataSource.deleteWorkout(id));

  @override
  Future<Either<Failure, void>> logout() async =>
      _guard(_remoteDataSource.logout);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (error) {
      return Left(ApiFailure(message: error.toString()));
    }
  }
}
