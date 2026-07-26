import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/auth/data/models/auth_hive_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ApiClient());
});

abstract class AuthRemoteDataSource {
  Future<AuthHiveModel> register(AuthHiveModel user);
  Future<AuthHiveModel> login(String email, String password);
  Future<AuthHiveModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  String _dioMessage(DioException error, String fallback) {
    final responseData = error.response?.data;
    if (responseData is Map && responseData['message'] != null) {
      return responseData['message'].toString();
    }
    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData;
    }
    if (error.message != null && error.message!.trim().isNotEmpty) {
      return error.message!;
    }
    return fallback;
  }

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    try {
      final requestData = user.toJson();
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: requestData,
      );

      if (response.statusCode == 201) {
        return AuthHiveModel.fromJson(response.data['data']);
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, 'Registration failed'));
    }
  }

  @override
  Future<AuthHiveModel> login(String email, String password) async {
    try {
      final requestData = {'email': email, 'password': password};
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        await _apiClient.saveToken(token);
        return AuthHiveModel.fromJson(response.data['data']);
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, 'Login failed'));
    }
  }

  @override
  Future<AuthHiveModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getMe);
      if (response.statusCode == 200) {
        return AuthHiveModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get user');
      }
    } on DioException catch (e) {
      throw Exception(_dioMessage(e, 'Failed to get user'));
    }
  }

  @override
  Future<void> logout() async {
    await _apiClient.clearToken();
  }
}
