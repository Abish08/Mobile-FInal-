import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/daily_log/data/models/daily_log_model.dart';

final dailyLogRemoteDataSourceProvider = Provider<DailyLogRemoteDataSource>((
  ref,
) {
  return DailyLogRemoteDataSourceImpl(ApiClient());
});

abstract class DailyLogRemoteDataSource {
  Future<DailyLogModel> getDailyLog(DateTime date);
  Future<void> deleteLog({required String id, required bool isWorkout});
}

class DailyLogRemoteDataSourceImpl implements DailyLogRemoteDataSource {
  final ApiClient _apiClient;

  DailyLogRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DailyLogModel> getDailyLog(DateTime date) async {
    try {
      final dateText = date.toIso8601String().split('T')[0];
      final foodRes = await _apiClient.dio.get(
        ApiEndpoints.foodLogs,
        queryParameters: {'date': dateText},
      );
      final workoutRes = await _apiClient.dio.get(
        ApiEndpoints.workoutLogs,
        queryParameters: {'date': dateText},
      );

      return DailyLogModel.fromResponses(
        foodResponse: Map<String, dynamic>.from(foodRes.data),
        workoutResponse: Map<String, dynamic>.from(workoutRes.data),
      );
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'Failed to load daily log';
      throw Exception(message);
    }
  }

  @override
  Future<void> deleteLog({required String id, required bool isWorkout}) async {
    try {
      final endpoint = isWorkout
          ? '${ApiEndpoints.workoutLogs}/$id'
          : '${ApiEndpoints.foodLogs}/$id';
      await _apiClient.dio.delete(endpoint);
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map && data['message'] != null
          ? data['message'].toString()
          : 'Failed to delete log';
      throw Exception(message);
    }
  }
}
