import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/workouts/data/models/workout_model.dart';
import 'package:nutri_nepal/features/workouts/domain/entities/workout_entity.dart';

final workoutRemoteDataSourceProvider = Provider<WorkoutRemoteDataSource>((
  ref,
) {
  return WorkoutRemoteDataSourceImpl(ApiClient());
});

abstract class WorkoutRemoteDataSource {
  Future<List<UserWorkout>> getWorkouts();
  Future<void> logWorkout({
    required String workoutId,
    required int duration,
    required DateTime date,
  });
}

class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  final ApiClient _apiClient;

  WorkoutRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<UserWorkout>> getWorkouts() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.publicWorkouts);
      return WorkoutModel.listFromResponse(response.data);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to load workouts'));
    }
  }

  @override
  Future<void> logWorkout({
    required String workoutId,
    required int duration,
    required DateTime date,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.workoutLogs,
        data: {
          'workoutId': workoutId,
          'duration': duration > 0 ? duration : 30,
          'date': date.toIso8601String().split('T')[0],
        },
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to log workout'));
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
