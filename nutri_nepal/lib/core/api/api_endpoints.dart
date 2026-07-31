import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = true;
  static const String _ipAddress = '192.168.101.13';
  static const int _port = 3000;

  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api/v1';
  static String get mediaServerUrl => serverUrl;
  static String get profileImages => '$mediaServerUrl/uploads';

  static String resolveUploadUrl(String raw, {String? defaultFolder}) {
    final value = raw.trim().replaceAll('\\', '/');
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      try {
        final uri = Uri.parse(value);
        if (uri.path.startsWith('/uploads/')) {
          return '$mediaServerUrl${uri.path}${uri.query.isEmpty ? '' : '?${uri.query}'}';
        }
        return value;
      } catch (e) {
        return value;
      }
    }
    if (value.startsWith('/uploads/')) return '$mediaServerUrl$value';
    if (value.startsWith('uploads/')) return '$mediaServerUrl/$value';
    if (value.contains('/')) return '$profileImages/$value';
    if (defaultFolder != null && defaultFolder.isNotEmpty) {
      return '$profileImages/$defaultFolder/$value';
    }
    return '$profileImages/$value';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth & User
  static const String login = '/users/login';
  static const String register = '/users/register';
  static const String forgotPassword = '/users/forgot-password';
  static const String resetPassword = '/users/reset-password';
  static const String getMe = '/users/me';
  static const String getProfile = '/healthProfile';
  static const String updateProfile = '/healthProfile';

  // Food & Food Logs
  static const String publicFoods = '/foods';
  static const String foodLogs = '/foodLogs';
  static const String meals = '/meals';

  // Workouts & Workout Logs
  static const String publicWorkouts = '/workouts/catalog';
  static const String workoutLogs = '/workoutLogs';

  // Progress
  static const String progressCalorieHistory = '/progress/history/calories';
  static const String progressWorkoutHistory = '/progress/history/workouts';
  static const String progressSummary = '/progress/summary';
  static const String progressCreate = '/progress';

  // Admin Endpoints
  static const String adminUsers = '/users';
  static String adminUserById(String id) => '/users/$id';
  static String adminDeleteUser(String id) => '/users/admin/$id';
  static String adminEditUser(String id) => '/users/admin/$id';
  static const String adminUserStats = '/users/admin/stats';

  static const String adminMeals = '/foods/admin/all';
  static const String adminMealStats = '/foods/admin/stats';
  static String adminFoodUpdate(String id) => '/foods/$id';
  static String adminFoodDelete(String id) => '/foods/$id';
  static const String adminWorkouts = '/workouts/admin/all';
  static const String adminWorkoutStats = '/workouts/admin/stats';
  static const String adminWorkoutCreate = '/workouts/admin';
  static String adminWorkoutUpdate(String id) => '/workouts/admin/$id';
  static String adminWorkoutDelete(String id) => '/workouts/admin/$id';

  // Upload Endpoints
  static const String uploadProfile = '/upload/profile';
  static const String uploadMeal = '/upload/meal';
}
