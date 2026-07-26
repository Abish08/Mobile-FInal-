import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/providers/refresh_provider.dart';
import 'package:nutri_nepal/features/admin/domain/entities/admin_entity.dart';
import 'package:nutri_nepal/features/admin/domain/usecases/admin_usecases.dart';

final adminProvider = AsyncNotifierProvider<AdminNotifier, AdminState>(
  AdminNotifier.new,
);

class AdminState extends Equatable {
  final AdminDashboardStats? dashboardStats;
  final AdminUserList? userList;
  final AdminFoodList? foodList;
  final List<AdminWorkout> workouts;

  const AdminState({
    this.dashboardStats,
    this.userList,
    this.foodList,
    this.workouts = const [],
  });

  const AdminState.empty()
    : dashboardStats = null,
      userList = null,
      foodList = null,
      workouts = const [];

  AdminState copyWith({
    AdminDashboardStats? dashboardStats,
    AdminUserList? userList,
    AdminFoodList? foodList,
    List<AdminWorkout>? workouts,
  }) {
    return AdminState(
      dashboardStats: dashboardStats ?? this.dashboardStats,
      userList: userList ?? this.userList,
      foodList: foodList ?? this.foodList,
      workouts: workouts ?? this.workouts,
    );
  }

  @override
  List<Object?> get props => [dashboardStats, userList, foodList, workouts];
}

class AdminNotifier extends AsyncNotifier<AdminState> {
  @override
  Future<AdminState> build() async => const AdminState.empty();

  Future<AdminDashboardStats?> loadDashboardStats() async {
    final previous = state.asData?.value ?? const AdminState.empty();
    state = const AsyncLoading();
    final result = await ref.read(adminUseCasesProvider).getDashboardStats();
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (stats) {
        state = AsyncData(previous.copyWith(dashboardStats: stats));
        return stats;
      },
    );
  }

  Future<AdminUserList?> loadUsers({
    required String search,
    required String goal,
  }) async {
    final previous = state.asData?.value ?? const AdminState.empty();
    state = const AsyncLoading();
    final result = await ref
        .read(adminUseCasesProvider)
        .getUsers(search: search, goal: goal);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (users) {
        state = AsyncData(previous.copyWith(userList: users));
        return users;
      },
    );
  }

  Future<bool> deleteUser(String id) async {
    final result = await ref.read(adminUseCasesProvider).deleteUser(id);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref.read(refreshProvider.notifier).refresh();
        return true;
      },
    );
  }

  Future<AdminFoodList?> loadFoods({
    required String search,
    required String category,
  }) async {
    final previous = state.asData?.value ?? const AdminState.empty();
    state = const AsyncLoading();
    final result = await ref
        .read(adminUseCasesProvider)
        .getFoods(search: search, category: category);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (foods) {
        state = AsyncData(previous.copyWith(foodList: foods));
        return foods;
      },
    );
  }

  Future<bool> saveFood(AdminFoodInput input) async {
    final result = await ref.read(adminUseCasesProvider).saveFood(input);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref.read(refreshProvider.notifier).refresh();
        return true;
      },
    );
  }

  Future<bool> deleteFood(String id) async {
    final result = await ref.read(adminUseCasesProvider).deleteFood(id);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref.read(refreshProvider.notifier).refresh();
        return true;
      },
    );
  }

  Future<List<AdminWorkout>?> loadWorkouts({required String category}) async {
    final previous = state.asData?.value ?? const AdminState.empty();
    state = const AsyncLoading();
    final result = await ref
        .read(adminUseCasesProvider)
        .getWorkouts(category: category);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return null;
      },
      (workouts) {
        state = AsyncData(previous.copyWith(workouts: workouts));
        return workouts;
      },
    );
  }

  Future<bool> saveWorkout(AdminWorkoutInput input) async {
    final result = await ref.read(adminUseCasesProvider).saveWorkout(input);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref.read(refreshProvider.notifier).refresh();
        return true;
      },
    );
  }

  Future<bool> deleteWorkout(String id) async {
    final result = await ref.read(adminUseCasesProvider).deleteWorkout(id);
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        ref.read(refreshProvider.notifier).refresh();
        return true;
      },
    );
  }

  Future<bool> logout() async {
    final result = await ref.read(adminUseCasesProvider).logout();
    return result.fold((failure) {
      state = AsyncError(failure.message, StackTrace.current);
      return false;
    }, (_) => true);
  }
}
