import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/health_profile/data/models/health_profile_model.dart';

final healthProfileRemoteDataSourceProvider =
    Provider<HealthProfileRemoteDataSource>((ref) {
  return HealthProfileRemoteDataSourceImpl(ApiClient());
});

abstract class HealthProfileRemoteDataSource {
  Future<HealthProfileModel> getProfile();
  Future<HealthProfileModel> saveProfile(HealthProfileModel profile);
}

class HealthProfileRemoteDataSourceImpl
    implements HealthProfileRemoteDataSource {
  final ApiClient _apiClient;

  HealthProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<HealthProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getProfile);
      return HealthProfileModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (error) {
      final message = error.response?.data['message'] ?? 'Failed to load health profile';
      throw Exception(message);
    }
  }

  @override
  Future<HealthProfileModel> saveProfile(HealthProfileModel profile) async {
    try {
      await _apiClient.dio.patch(
        '/users/profile',
        data: profile.toUserProfileJson(),
      );

      final response = await _apiClient.dio.patch(
        ApiEndpoints.updateProfile,
        data: profile.toHealthProfileJson(),
      );

      return HealthProfileModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (error) {
      final message = error.response?.data['message'] ?? 'Failed to save health profile';
      throw Exception(message);
    }
  }
}
