import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/profile/data/models/profile_model.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  return ProfileRemoteDataSourceImpl(ApiClient());
});

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(ProfileModel profile);
  Future<ProfileModel> uploadProfileImage(File imageFile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getMe);
      return ProfileModel.fromResponse(response.data);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to load profile'));
    }
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final response = await _apiClient.dio.patch(
        '/users/profile',
        data: profile.toUpdateJson(),
      );
      return ProfileModel.fromResponse(response.data);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to update profile'));
    }
  }

  @override
  Future<ProfileModel> uploadProfileImage(File imageFile) async {
    try {
      final fileName = basename(imageFile.path);
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final uploadResponse = await _apiClient.dio.post(
        ApiEndpoints.uploadProfile,
        data: formData,
      );
      final imageUrl = uploadResponse.data['imageUrl'];
      if (imageUrl == null || imageUrl.toString().trim().isEmpty) {
        throw Exception('Upload did not return an image URL');
      }

      final profileResponse = await _apiClient.dio.patch(
        '/users/profile',
        data: {'profilePicture': imageUrl.toString()},
      );
      return ProfileModel.fromResponse(profileResponse.data);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Failed to upload profile image'));
    }
  }

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return error.message ?? fallback;
  }
}
