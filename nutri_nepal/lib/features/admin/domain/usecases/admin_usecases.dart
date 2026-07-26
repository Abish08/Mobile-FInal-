import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:nutri_nepal/features/admin/domain/entities/admin_entity.dart';
import 'package:nutri_nepal/features/admin/domain/repositories/admin_repository.dart';

final adminUseCasesProvider = Provider<AdminUseCases>((ref) {
  return AdminUseCases(ref.read(adminRepositoryProvider));
});

class AdminUseCases {
  final IAdminRepository _repository;

  AdminUseCases(this._repository);

  Future<Either<Failure, AdminDashboardStats>> getDashboardStats() {
    return _repository.getDashboardStats();
  }

  Future<Either<Failure, AdminUserList>> getUsers({
    required String search,
    required String goal,
  }) {
    return _repository.getUsers(search: search, goal: goal);
  }

  Future<Either<Failure, void>> deleteUser(String id) {
    return _repository.deleteUser(id);
  }

  Future<Either<Failure, AdminFoodList>> getFoods({
    required String search,
    required String category,
  }) {
    return _repository.getFoods(search: search, category: category);
  }

  Future<Either<Failure, String>> saveFood(AdminFoodInput input) {
    return _repository.saveFood(input);
  }

  Future<Either<Failure, void>> deleteFood(String id) {
    return _repository.deleteFood(id);
  }

  Future<Either<Failure, List<AdminWorkout>>> getWorkouts({
    required String category,
  }) {
    return _repository.getWorkouts(category: category);
  }

  Future<Either<Failure, String>> saveWorkout(AdminWorkoutInput input) {
    return _repository.saveWorkout(input);
  }

  Future<Either<Failure, void>> deleteWorkout(String id) {
    return _repository.deleteWorkout(id);
  }

  Future<Either<Failure, void>> logout() {
    return _repository.logout();
  }
}
