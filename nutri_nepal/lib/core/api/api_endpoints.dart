import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const String _physicalDeviceHost = '192.168.1.67';
  static const String _configuredHost = String.fromEnvironment('API_HOST');
  static const int _port = int.fromEnvironment(
    'API_PORT',
    defaultValue: 3000,
  );
  static String? _activeHost;

  static String get _host {
    if (_activeHost != null) return _activeHost!;
    if (_configuredHost.isNotEmpty) return _configuredHost;
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return 'localhost';
    }
    // Mobile builds default to the LAN address so existing physical-device
    // runs keep working. Emulators override this with API_HOST=10.0.2.2.
    if (Platform.isAndroid || Platform.isIOS) return _physicalDeviceHost;
    return 'localhost';
  }

  static String? get fallbackHost {
    if (kIsWeb) return null;
    if (_configuredHost == '10.0.2.2') {
      return _physicalDeviceHost;
    }
    if (_configuredHost.isNotEmpty || !Platform.isAndroid) {
      return null;
    }
    if (_host == _physicalDeviceHost) return '10.0.2.2';
    return null;
  }

  static String? get fallbackBaseUrl {
    final host = fallbackHost;
    return host == null ? null : 'http://$host:$_port/api/v1';
  }

  static void useHost(String host) {
    _activeHost = host;
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

  // AI
  static const String aiChat = '/ai/chat';

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
