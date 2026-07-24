import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';

class DailyLogScreen extends ConsumerStatefulWidget {
  const DailyLogScreen({super.key});

  @override
  ConsumerState<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends ConsumerState<DailyLogScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _todayMeals = [];
  List<Map<String, dynamic>> _todayWorkouts = [];
  int _calorieGoal = 2500;

  @override
  void initState() {
    super.initState();
    _loadDailyLog();
  }

  Future<void> _loadDailyLog() async {
    setState(() => _isLoading = true);
    final apiClient = ApiClient();

    try {
      // 1. Fetch User Profile for Calorie Goal
      final profileRes = await apiClient.dio.get(ApiEndpoints.getProfile);
      if (profileRes.statusCode == 200) {
        final userData = profileRes.data['data'] ?? profileRes.data;
        _calorieGoal = (userData['calorieGoal'] ?? 2500).toInt();
      }

      // 2. Fetch Meals and Workouts
      final mealsRes = await apiClient.dio.get(ApiEndpoints.meals);
      final workoutsRes = await apiClient.dio.get('/workouts');

      List<dynamic> allMealsData = [];
      List<dynamic> allWorkoutsData = [];

      if (mealsRes.statusCode == 200) {
        allMealsData = mealsRes.data['data'] ?? mealsRes.data;
      }
      if (workoutsRes.statusCode == 200) {
        allWorkoutsData = workoutsRes.data['data'] ?? workoutsRes.data;
      }

      final today = DateTime.now();
      _todayMeals = allMealsData.where((meal) {
        final dateStr = meal['createdAt'] ?? meal['date'];
        return _isSameDay(dateStr, today);
      }).map((e) => e as Map<String, dynamic>).toList();

      _todayWorkouts = allWorkoutsData.where((workout) {
        final dateStr = workout['createdAt'] ?? workout['date'];
        return _isSameDay(dateStr, today);
      }).map((e) => e as Map<String, dynamic>).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading daily log: $e');
      setState(() => _isLoading = false);
    }
  }

  bool _isSameDay(dynamic dateStr, DateTime target) {
    if (dateStr == null) return false;
    try {
      final date = dateStr is DateTime ? dateStr : DateTime.parse(dateStr.toString());
      return date.year == target.year && date.month == target.month && date.day == target.day;
    } catch (e) {
      return false;
    }
  }

// --- Calculations ---
int get _totalConsumed => _todayMeals.fold<int>(0, (sum, meal) {
  final cals = meal['calories'];
  if (cals == null) return sum;
  final calValue = cals is int ? cals : (cals is double ? cals.toInt() : 0);
  return sum + calValue;
});

int get _totalBurned => _todayWorkouts.fold<int>(0, (sum, w) {
  final cals = w['caloriesBurned'];
  if (cals == null) return sum;
  final calValue = cals is int ? cals : (cals is double ? cals.toInt() : 0);
  return sum + calValue;
});

int get _netCalories => _totalConsumed - _totalBurned;
int get _remaining => _calorieGoal - _netCalories;
double get _progress => (_netCalories / _calorieGoal).clamp(0.0, 1.0);

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daily Log',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1B4332)),
            onPressed: _loadDailyLog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
          : RefreshIndicator(
              onRefresh: _loadDailyLog,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calories Remaining Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REMAINING',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_remaining',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const Text(
                            'kcal',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Goal: $_calorieGoal',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB85C00)),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildCalorieStat('$_totalConsumed', 'CONSUMED'),
                              Container(width: 1, height: 30, color: Colors.white24),
                              _buildCalorieStat('$_totalBurned', 'BURNED'),
                              Container(width: 1, height: 30, color: Colors.white24),
                              _buildCalorieStat('$_netCalories', 'NET'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Meals Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Meals',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Add Meal feature coming soon!'),
                                backgroundColor: Color(0xFF1B4332),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Meal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB85C00),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_todayMeals.isEmpty)
                      _buildEmptyState('No meals logged today', Icons.restaurant_menu)
                    else
                      ..._todayMeals.map((meal) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildLogItem(
                              Icons.restaurant,
                              meal['name'] ?? 'Unknown Meal',
                              '${meal['calories'] ?? 0} kcal • ${_formatTime(meal['createdAt'])}',
                              Colors.orange,
                            ),
                          )),

                    const SizedBox(height: 24),

                    // Exercises Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Exercises',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Add Activity feature coming soon!'),
                                backgroundColor: Color(0xFF1B4332),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Activity'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB85C00),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_todayWorkouts.isEmpty)
                      _buildEmptyState('No exercises logged today', Icons.fitness_center)
                    else
                      ..._todayWorkouts.map((workout) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildExerciseLogItem(
                              Icons.fitness_center,
                              workout['name'] ?? 'Unknown Workout',
                              '-${workout['caloriesBurned'] ?? 0} kcal • ${workout['duration'] ?? 0} mins',
                              Colors.blue,
                            ),
                          )),

                    const SizedBox(height: 24),

                    // Hydration Tip
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4332).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1B4332).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B4332).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.water_drop,
                              color: Color(0xFF1B4332),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hydration matters',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Drinking water before meals can help with calorie control and boost metabolism by 24-30%.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                    fontFamily: 'OpenSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCalorieStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }

  Widget _buildLogItem(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontFamily: 'OpenSans',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseLogItem(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontFamily: 'OpenSans',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}