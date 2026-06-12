import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    try {
      final requestData = user.toJson();
      print('AuthRemoteDataSource.register: request=$requestData');
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: requestData,
      );
      print('AuthRemoteDataSource.register: status=${response.statusCode} data=${response.data}');

      if (response.statusCode == 201) {
        return AuthHiveModel.fromJson(response.data['data']);
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Registration failed';
      print('AuthRemoteDataSource.register error: $message');
      throw Exception(message);
    }
  }

  @override
  Future<AuthHiveModel> login(String email, String password) async {
    try {
      final requestData = {
        'email': email,
        'password': password,
      };
      print('AuthRemoteDataSource.login: request=email=$email passwordLength=${password.length}');
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: requestData,
      );
      print('AuthRemoteDataSource.login: status=${response.statusCode} data=${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        await _apiClient.saveToken(token);
        return AuthHiveModel.fromJson(response.data['data']);
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Login failed';
      print('AuthRemoteDataSource.login error: $message');
      throw Exception(message);
    }
  }

  @override
  Future<AuthHiveModel> getCurrentUser() async {
    try {
      print('AuthRemoteDataSource.getCurrentUser');
      final response = await _apiClient.get(ApiEndpoints.getMe);
      print('AuthRemoteDataSource.getCurrentUser: status=${response.statusCode} data=${response.data}');
      if (response.statusCode == 200) {
        return AuthHiveModel.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to get user');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to get user';
      print('AuthRemoteDataSource.getCurrentUser error: $message');
      throw Exception(message);
    }
  }

  @override
  Future<void> logout() async {
    print('AuthRemoteDataSource.logout');
    await _apiClient.clearToken();
  }
}