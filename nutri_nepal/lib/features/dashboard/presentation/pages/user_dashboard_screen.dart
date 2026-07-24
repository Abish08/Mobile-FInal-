import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/auth/presentation/view_model/auth_viewmodel.dart';

class UserDashboardScreen extends ConsumerStatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  ConsumerState<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends ConsumerState<UserDashboardScreen> {
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // ✅ Safe type conversion helpers
  int _toInt(dynamic val) => val == null ? 0 : (val is int ? val : val.toDouble().toInt());
  double _toDouble(dynamic val) => val == null ? 0.0 : (val is double ? val : val.toDouble());

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ApiClient();
      
      final profileRes = await apiClient.dio.get(ApiEndpoints.getProfile);
      final mealsRes = await apiClient.dio.get(ApiEndpoints.meals);
      final workoutsRes = await apiClient.dio.get('/workouts');

      if (profileRes.statusCode == 200) {
        setState(() {
          _dashboardData = {
            'user': profileRes.data['data'] ?? profileRes.data,
            'meals': mealsRes.statusCode == 200 ? (mealsRes.data['data'] ?? []) : [],
            'workouts': workoutsRes.statusCode == 200 ? (workoutsRes.data['data'] ?? []) : [],
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      setState(() => _isLoading = false);
    }
  }

  double _calculateBMI(double weight, double heightCm) {
    final heightM = heightCm / 100;
    return weight / (heightM * heightM);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1B4332))),
      );
    }

    final userData = _dashboardData['user'] as Map<String, dynamic>?;
    final meals = _dashboardData['meals'] as List? ?? [];
    final workouts = _dashboardData['workouts'] as List? ?? [];

    // ✅ Safe math calculations
    final totalCalories = meals.fold<int>(0, (sum, meal) => sum + _toInt(meal['calories']));
    final totalProtein = meals.fold<double>(0.0, (sum, meal) => sum + _toDouble(meal['protein']));
    final totalCarbs = meals.fold<double>(0.0, (sum, meal) => sum + _toDouble(meal['carbs']));
    final totalFats = meals.fold<double>(0.0, (sum, meal) => sum + _toDouble(meal['fats']));

    final weight = _toDouble(userData?['weight'] ?? 70.0);
    final height = _toDouble(userData?['height'] ?? 170.0);
    final bmi = _calculateBMI(weight, height);
    final bmiCategory = _getBMICategory(bmi);
    final bmiColor = _getBMIColor(bmi);
    final calorieGoal = 2500; // You can make this dynamic based on user goals later

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Namaste, ${userData?['firstName'] ?? 'User'}',
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1B4332)),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You\'re ${((totalCalories / calorieGoal) * 100).toStringAsFixed(0)}% towards your goal today',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontFamily: 'OpenSans'),
              ),
              const SizedBox(height: 24),

              _buildBMICard(bmi, bmiCategory, bmiColor),
              const SizedBox(height: 16),

              _buildCaloriesCard(totalCalories, calorieGoal),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildMacroCard('Protein', '${totalProtein.toStringAsFixed(1)}g', Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMacroCard('Carbs', '${totalCarbs.toStringAsFixed(1)}g', Colors.green)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMacroCard('Fats', '${totalFats.toStringAsFixed(1)}g', Colors.orange)),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Daily Agenda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 16),

              if (meals.isNotEmpty) ...[
                _buildAgendaItem(Icons.restaurant, meals.first['name'] ?? 'Meal', '${_toInt(meals.first['calories'])} kcal', Colors.orange),
                const SizedBox(height: 12),
              ],
              if (workouts.isNotEmpty) ...[
                _buildAgendaItem(Icons.fitness_center, workouts.first['name'] ?? 'Workout', '45 Mins', const Color(0xFF1B4332)),
              ],
              if (meals.isEmpty && workouts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('No activities logged today', style: TextStyle(color: Color(0xFF6B7280)))),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMICard(double bmi, String category, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YOUR BODY MASS INDEX', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontFamily: 'Montserrat')),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bmi.toStringAsFixed(1), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color, fontFamily: 'Montserrat')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, fontFamily: 'Montserrat')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: (bmi / 40).clamp(0.0, 1.0), backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(int consumed, int goal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)]), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DAILY CALORIES', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Montserrat')),
          const SizedBox(height: 8),
          Text('$consumed', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
          Text('/ $goal kcal', style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'OpenSans')),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: (consumed / goal).clamp(0.0, 1.0), backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB85C00)), minHeight: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          SizedBox(
            width: 50, height: 50,
            child: Stack(fit: StackFit.expand, children: [
              CircularProgressIndicator(value: 0.7, strokeWidth: 4, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(color)),
              Center(child: Icon(label == 'Protein' ? Icons.fitness_center : label == 'Carbs' ? Icons.bakery_dining : Icons.water_drop, color: color, size: 24)),
            ]),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, fontFamily: 'Montserrat')),
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontFamily: 'OpenSans')),
        ],
      ),
    );
  }

  Widget _buildAgendaItem(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), fontFamily: 'Montserrat')),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontFamily: 'OpenSans')),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }
}