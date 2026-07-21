// lib/core/api/api_endpoints.dart

import 'package:nutri_nepal/core/constants/hive_table_constant.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  static const bool isPhysicalDevice = false;
  static const String _ipAddress = '192.168.101.2'; // ✅ Your actual IP from ipconfig
  static const int _port = 3000;

  // Base URLs
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api/v1'; // ✅ Updated to match your backend
  static String get mediaServerUrl => serverUrl;

  static String get profileImages => '$mediaServerUrl/uploads';
  static String resolveUploadUrl(String raw, {String? defaultFolder}) {
    final value = raw.trim().replaceAll('\\', '/');
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/uploads/')) {
      return '$mediaServerUrl$value';
    }

    if (value.startsWith('uploads/')) {
      return '$mediaServerUrl/$value';
    }

    if (value.contains('/')) {
      return '$profileImages/$value';
    }

    if (defaultFolder != null && defaultFolder.isNotEmpty) {
      return '$profileImages/$defaultFolder/$value';
    }

    return '$profileImages/$value';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth Endpoints ============
  static const String register = '/users/register';
  static const String login = '/users/login';
  static const String getMe = '/users/me';
  static const String updateProfile = '/users/profile';

  // ============ User Endpoints ============
  static const String users = '/users'; // ✅ Already exists in your backend
  static String userById(String id) => '/users/$id'; // ✅ Already exists in your backend
  static String deleteUser(String id) => '/users/$id'; // ✅ Already exists in your backend

  // ============ Meal Endpoints ============
  static const String meals = '/meals'; // ✅ Already exists in your backend
  static String mealById(String id) => '/meals/$id'; // ✅ Already exists in your backend
  static const String addMeal = '/meals'; // ✅ POST endpoint for new meals
  static String editMeal(String id) => '/meals/$id'; // ✅ PUT/PATCH endpoint

  // ============ Workout Endpoints ============
  static const String workouts = '/workouts'; // ✅ Already exists in your backend
  static String workoutById(String id) => '/workouts/$id'; // ✅ Already exists in your backend
  static const String addWorkout = '/workouts'; // ✅ POST endpoint for new workouts
  static String editWorkout(String id) => '/workouts/$id'; // ✅ PUT/PATCH endpoint

  // ============ Upload Endpoints ============
  static const String uploadProfile = '/upload/profile'; // ✅ POST endpoint
  static const String uploadMeal = '/upload/meal'; // ✅ POST endpoint
  static const String uploadWorkout = '/upload/workout'; // ✅ POST endpoint
}