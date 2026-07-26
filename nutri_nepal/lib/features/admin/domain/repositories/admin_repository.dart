import 'package:dartz/dartz.dart';
import 'package:nutri_nepal/core/error/failures.dart';
import 'package:nutri_nepal/features/admin/domain/entities/admin_entity.dart';

abstract class IAdminRepository {
  Future<Either<Failure, AdminDashboardStats>> getDashboardStats();
  Future<Either<Failure, AdminUserList>> getUsers({
    required String search,
    required String goal,
  });
  Future<Either<Failure, void>> deleteUser(String id);
  Future<Either<Failure, AdminFoodList>> getFoods({
    required String search,
    required String category,
  });
  Future<Either<Failure, String>> saveFood(AdminFoodInput input);
  Future<Either<Failure, void>> deleteFood(String id);
  Future<Either<Failure, List<AdminWorkout>>> getWorkouts({
    required String category,
  });
  Future<Either<Failure, String>> saveWorkout(AdminWorkoutInput input);
  Future<Either<Failure, void>> deleteWorkout(String id);
  Future<Either<Failure, void>> logout();
}
