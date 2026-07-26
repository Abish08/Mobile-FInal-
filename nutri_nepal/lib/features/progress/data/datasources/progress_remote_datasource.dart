import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/progress/data/models/progress_model.dart';
import 'package:nutri_nepal/features/progress/domain/entities/progress_entity.dart';

final progressRemoteDataSourceProvider = Provider<ProgressRemoteDataSource>((
  ref,
) {
  return ProgressRemoteDataSourceImpl(ApiClient());
});

abstract class ProgressRemoteDataSource {
  Future<ProgressSummaryEntity> getSummary();
  Future<List<ProgressPointEntity>> getCalorieHistory({int days = 30});
  Future<List<ProgressPointEntity>> getWorkoutHistory({int days = 30});
  Future<void> addProgress({required double weight});
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  final ApiClient _apiClient;

  ProgressRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ProgressSummaryEntity> getSummary() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.progressSummary);
      return ProgressSummaryModel.fromResponse(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to load progress summary'));
    }
  }

  @override
  Future<List<ProgressPointEntity>> getCalorieHistory({int days = 30}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.progressCalorieHistory,
        queryParameters: {'days': days},
      );
      return ProgressPointModel.listFromResponse(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to load weight history'));
    }
  }

  @override
  Future<List<ProgressPointEntity>> getWorkoutHistory({int days = 30}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.progressWorkoutHistory,
        queryParameters: {'days': days},
      );
      return ProgressPointModel.listFromResponse(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to load workout history'));
    }
  }

  @override
  Future<void> addProgress({required double weight}) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.progressCreate,
        data: {'weight': weight},
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to add progress entry'));
    }
  }

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return fallback;
  }
}
