import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/admin/data/models/admin_model.dart';
import 'package:nutri_nepal/features/admin/domain/entities/admin_entity.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSourceImpl(ApiClient());
});

abstract class AdminRemoteDataSource {
  Future<AdminDashboardStats> getDashboardStats();
  Future<AdminUserList> getUsers({
    required String search,
    required String goal,
  });
  Future<void> deleteUser(String id);
  Future<AdminFoodList> getFoods({
    required String search,
    required String category,
  });
  Future<String> saveFood(AdminFoodInput input);
  Future<void> deleteFood(String id);
  Future<List<AdminWorkout>> getWorkouts({required String category});
  Future<String> saveWorkout(AdminWorkoutInput input);
  Future<void> deleteWorkout(String id);
  Future<void> logout();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient _apiClient;

  AdminRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      final userStats = await _apiClient.dio.get(ApiEndpoints.adminUserStats);
      final foodStats = await _apiClient.dio.get(ApiEndpoints.adminMealStats);
      final workouts = await _apiClient.dio.get(ApiEndpoints.adminWorkouts);
      return AdminModel.dashboardStats(
        userStatsResponse: userStats.data,
        foodStatsResponse: foodStats.data,
        workoutsResponse: workouts.data,
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to load admin dashboard'));
    }
  }

  @override
  Future<AdminUserList> getUsers({
    required String search,
    required String goal,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.adminUsers,
        queryParameters: {'search': search, 'goal': goal, 'sortBy': 'newest'},
      );
      return AdminModel.userList(response.data);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to load users'));
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.adminDeleteUser(id));
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to delete user'));
    }
  }

  @override
  Future<AdminFoodList> getFoods({
    required String search,
    required String category,
  }) async {
    try {
      final stats = await _apiClient.dio.get(ApiEndpoints.adminMealStats);
      final foods = await _apiClient.dio.get(
        ApiEndpoints.adminMeals,
        queryParameters: {'search': search, 'category': category},
      );
      return AdminModel.foodList(
        foodsResponse: foods.data,
        statsResponse: stats.data,
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to load foods'));
    }
  }

  @override
  Future<String> saveFood(AdminFoodInput input) async {
    try {
      final data = AdminFoodModel.inputToJson(input);
      final String foodId;
      if (input.id != null) {
        foodId = input.id!;
        await _apiClient.dio.put(
          ApiEndpoints.adminFoodUpdate(foodId),
          data: data,
        );
      } else {
        final response = await _apiClient.dio.post('/foods', data: data);
        foodId = _idFromResponse(response.data);
      }

      if (input.thumbnailImage != null) {
        await _uploadSingle(
          endpoint: '/foods/$foodId/upload-thumbnail',
          file: input.thumbnailImage!,
          field: 'thumbnail',
        );
      }
      if (input.additionalImages.isNotEmpty) {
        await _uploadMany(
          endpoint: '/foods/$foodId/upload-images',
          files: input.additionalImages,
          field: 'images',
        );
      }
      return foodId;
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to save food'));
    }
  }

  @override
  Future<void> deleteFood(String id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.adminFoodDelete(id));
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to delete food'));
    }
  }

  @override
  Future<List<AdminWorkout>> getWorkouts({required String category}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.adminWorkouts,
        queryParameters: {'category': category},
      );
      return AdminModel.workoutList(response.data);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to load workouts'));
    }
  }

  @override
  Future<String> saveWorkout(AdminWorkoutInput input) async {
    try {
      final data = AdminWorkoutModel.inputToJson(input);
      final String workoutId;
      if (input.id != null) {
        workoutId = input.id!;
        await _apiClient.dio.put(
          ApiEndpoints.adminWorkoutUpdate(workoutId),
          data: data,
        );
      } else {
        final response = await _apiClient.dio.post(
          ApiEndpoints.adminWorkoutCreate,
          data: data,
        );
        workoutId = _idFromResponse(response.data);
      }

      if (input.thumbnailImage != null) {
        await _uploadSingle(
          endpoint: '/workouts/$workoutId/upload-thumbnail',
          file: input.thumbnailImage!,
          field: 'thumbnail',
        );
      }
      if (input.additionalImages.isNotEmpty) {
        await _uploadMany(
          endpoint: '/workouts/$workoutId/upload-images',
          files: input.additionalImages,
          field: 'images',
        );
      }
      return workoutId;
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to save workout'));
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.adminWorkoutDelete(id));
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to delete workout'));
    }
  }

  @override
  Future<void> logout() async {
    await _apiClient.clearToken();
  }

  Future<void> _uploadSingle({
    required String endpoint,
    required File file,
    required String field,
  }) async {
    final formData = FormData.fromMap({
      field: await MultipartFile.fromFile(
        file.path,
        filename: basename(file.path),
      ),
    });
    await _apiClient.dio.post(endpoint, data: formData);
  }

  Future<void> _uploadMany({
    required String endpoint,
    required List<File> files,
    required String field,
  }) async {
    final multipartFiles = <MultipartFile>[];
    for (final file in files) {
      multipartFiles.add(
        await MultipartFile.fromFile(file.path, filename: basename(file.path)),
      );
    }
    await _apiClient.dio.post(
      endpoint,
      data: FormData.fromMap({field: multipartFiles}),
    );
  }

  String _idFromResponse(dynamic data) {
    final value = data is Map
        ? ((data['data'] as Map?)?['_id'] ?? data['_id'])
        : null;
    if (value is Map) return value['\$oid']?.toString() ?? '';
    return value?.toString() ?? '';
  }

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return error.message ?? fallback;
  }
}
