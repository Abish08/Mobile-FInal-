class ApiEndpoints {
  // For physical device (your OPPO phone)
  // NOTE: Update this IP if it changes (check with: ipconfig)
static const String baseUrl = 'http://192.168.101.2:3000/api/v1'; // static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  
  // Auth Endpoints
  static const String register = '/users/register';
  static const String login = '/users/login';
  static const String getMe = '/users/me';
  
  // User Endpoints
  static String user(String id) => '/users/$id';
  
  // Meal Endpoints
  static const String meals = '/meals';
  static String meal(String id) => '/meals/$id';
  
  // Workout Endpoints
  static const String workouts = '/workouts';
  static String workout(String id) => '/workouts/$id';
  
  // Progress Endpoints
  static const String progress = '/progress';
  static String progressEntry(String id) => '/progress/$id';
}