import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import '../api/api_client.dart';

class ImageUploadService {
  final Dio _dio;
  final ImagePicker _picker;

  ImageUploadService()
      : _dio = ApiClient().dio,
        _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final fileName = basename(imageFile.path);
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/upload/profile',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['imageUrl'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadMealPicture(File imageFile) async {
    try {
      final fileName = basename(imageFile.path);
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/upload/meal',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['imageUrl'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
