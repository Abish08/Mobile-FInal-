import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  static const bool isPhysicalDevice = true;
  static const String _ipAddress = '192.168.101.10';
  static const int _port = 3000;

  // Base URLs
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
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
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

  // User Endpoints
  static const String users = '/users';
  static const String login = '/users/login';
  static const String register = '/users/register';
  static String userById(String id) => '/users/$id';
  static const String getMe = '/users/me';
  static const String getProfile = '/users/me';
  static const String editProfile = '/users/profile';

  //  Admin User Endpoints
  static const String adminUsers = '/users';
  static String adminUserById(String id) => '/users/$id';
  static String adminDeleteUser(String id) => '/users/$id';
  static String adminEditUser(String id) => '/users/$id';
  static const String adminUserStats = '/users/admin/stats';

  // Meal Endpoints (User logging)
  static const String meals = '/meals';
  static String mealById(String id) => '/meals/$id';
  static const String mealCreate = '/meals';
  static String mealUpdate(String id) => '/meals/$id';
  static String mealDelete(String id) => '/meals/$id';

  //  Admin Food Endpoints (Database collection is 'foods')
  static const String adminMeals = '/foods/admin/all';
  static const String adminMealStats = '/foods/admin/stats';

  // Workout Endpoints
  static String workoutById(String id) => '/workouts/$id';
  static const String workoutCreate = '/workouts';
  static String workoutUpdate(String id) => '/workouts/$id';
  static String workoutDelete(String id) => '/workouts/$id';

  //  Admin Workout Endpoints
  static const String adminWorkouts = '/workouts/admin/all';
  static const String adminWorkoutStats = '/workouts/admin/stats';
  static const String adminWorkoutCreate = '/workouts/admin';
  static String adminWorkoutUpdate(String id) => '/workouts/admin/$id';
  static String adminWorkoutDelete(String id) => '/workouts/admin/$id';

  // Progress Endpoints
  static const String progress = '/progress';
  static String progressById(String id) => '/progress/$id';
  static const String progressCreate = '/progress';
  static String progressUpdate(String id) => '/progress/$id';
  static String progressDelete(String id) => '/progress/$id';

  //  Upload Endpoints 
  static const String uploadProfile = '/upload/profile';
  static const String uploadMeal = '/upload/meal';
  static const String uploadWorkout = '/upload/workout';

    //  Public Food Endpoints (For Users)
  static const String publicFoods = '/foods'; // Fetches all approved foods

   // User Workout Endpoints
  static const String publicWorkouts = '/workouts/catalog';
}