import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/admin/presentation/pages/user_management_screen.dart';
import 'package:nutri_nepal/features/admin/presentation/pages/meal_management_screen.dart';
import 'package:nutri_nepal/features/admin/presentation/pages/workout_management_screen.dart'; // ✅ ADDED IMPORT

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _totalUsers = 0;
  int _totalFoodItems = 0;
  int _totalWorkouts = 0;
  int _activeToday = 0;
  
  Map<String, int> _fitnessGoals = {
    'Weight Loss': 0,
    'Muscle Gain': 0,
    'Endurance': 0,
    'Maintenance': 0,
  };
  
  List<PieChartSectionData> _bmiDistribution = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final apiClient = ApiClient();
    
    try {
      // 1. User Stats
      final userStatsRes = await apiClient.dio.get(ApiEndpoints.adminUserStats);
      if (userStatsRes.statusCode == 200) {
        final stats = userStatsRes.data['stats'] ?? {};
        
        // Process Fitness Goals
        final goals = stats['usersByGoal'] as List? ?? [];
        Map<String, int> tempGoals = {
          'Weight Loss': 0, 'Muscle Gain': 0, 'Endurance': 0, 'Maintenance': 0
        };
        
        for (var goal in goals) {
          String goalName = (goal['_id'] ?? 'Unknown').toString();
          if (goalName.toLowerCase().contains('weight') || goalName.toLowerCase().contains('loss')) {
            goalName = 'Weight Loss';
          } else if (goalName.toLowerCase().contains('muscle') || goalName.toLowerCase().contains('gain')) {
            goalName = 'Muscle Gain';
          } else if (goalName.toLowerCase().contains('endurance')) {
            goalName = 'Endurance';
          } else if (goalName.toLowerCase().contains('maintain') || goalName.toLowerCase().contains('maintenance')) {
            goalName = 'Maintenance';
          }
          
          int count = (goal['count'] ?? 0).toInt();
          tempGoals[goalName] = (tempGoals[goalName] ?? 0) + count;
        }
        
        // Process BMI Distribution
        final bmiData = stats['bmiDistribution'] as List? ?? [];
        int underweight = 0, normal = 0, overweight = 0, obese = 0;
        
        for (var bmi in bmiData) {
          String category = (bmi['_id'] ?? '').toString().toLowerCase();
          int count = (bmi['count'] ?? 0).toInt();
          
          if (category.contains('under')) underweight += count;
          else if (category.contains('normal')) normal += count;
          else if (category.contains('over')) overweight += count;
          else if (category.contains('obese')) obese += count;
        }
        
        int totalBmi = underweight + normal + overweight + obese;
        if (totalBmi == 0) totalBmi = 1;

        setState(() {
          _totalUsers = (stats['totalUsers'] ?? 0).toInt();
          _activeToday = (stats['newToday'] ?? 0).toInt();
          _fitnessGoals = tempGoals;
          
          _bmiDistribution = [
            PieChartSectionData(
              value: underweight.toDouble(), 
              color: Colors.blue, 
              title: '${(underweight / totalBmi * 100).toStringAsFixed(0)}%', 
              radius: 50, 
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            PieChartSectionData(
              value: normal.toDouble(), 
              color: Colors.green, 
              title: '${(normal / totalBmi * 100).toStringAsFixed(0)}%', 
              radius: 50, 
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            PieChartSectionData(
              value: overweight.toDouble(), 
              color: Colors.orange, 
              title: '${(overweight / totalBmi * 100).toStringAsFixed(0)}%', 
              radius: 50, 
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            PieChartSectionData(
              value: obese.toDouble(), 
              color: Colors.red, 
              title: '${(obese / totalBmi * 100).toStringAsFixed(0)}%', 
              radius: 50, 
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ];
        });
      }
      
      // 2. Food Stats
      final foodStatsRes = await apiClient.dio.get(ApiEndpoints.adminMealStats);
      if (foodStatsRes.statusCode == 200) {
        setState(() {
          _totalFoodItems = (foodStatsRes.data['stats']['totalItems'] ?? 0).toInt();
        });
      }
      
      // 3. Workout Stats - Direct count from workouts collection
      try {
        final workoutRes = await apiClient.dio.get(ApiEndpoints.adminWorkouts);
        if (workoutRes.statusCode == 200) {
          final workouts = workoutRes.data['workouts'] as List? ?? [];
          setState(() {
            _totalWorkouts = workouts.length;
          });
        }
      } catch (e) {
        debugPrint('Error loading workouts: $e');
      }
      
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332), // Dark green
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontFamily: 'Montserrat', 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('System Performance'),
                    const SizedBox(height: 12),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Users by Fitness Goal'),
                    const SizedBox(height: 12),
                    _buildFitnessGoals(),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('BMI Distribution'),
                    const SizedBox(height: 12),
                    _buildBmiDistribution(),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Quick Actions'),
                    const SizedBox(height: 12),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5, // Fixed aspect ratio to prevent overflow
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard('$_totalUsers', 'Total Users', Colors.green, Icons.people),
        _buildStatCard('$_totalFoodItems', 'Total Foods', Colors.blue, Icons.restaurant),
        _buildStatCard('$_totalWorkouts', 'Total Workouts', Colors.orange, Icons.fitness_center),
        _buildStatCard('$_activeToday', 'Active Today', Colors.purple, Icons.visibility),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: color, 
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12, 
              color: Color(0xFF6B7280), 
              fontFamily: 'OpenSans',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessGoals() {
    int total = _fitnessGoals.values.reduce((a, b) => a + b);
    if (total == 0) total = 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildGoalRow('Weight Loss', Colors.red, _fitnessGoals['Weight Loss']!, total),
          const SizedBox(height: 12),
          _buildGoalRow('Muscle Gain', Colors.green, _fitnessGoals['Muscle Gain']!, total),
          const SizedBox(height: 12),
          _buildGoalRow('Endurance', Colors.blue, _fitnessGoals['Endurance']!, total),
          const SizedBox(height: 12),
          _buildGoalRow('Maintenance', Colors.orange, _fitnessGoals['Maintenance']!, total),
        ],
      ),
    );
  }

  Widget _buildGoalRow(String label, Color color, int count, int total) {
    double percentage = (count / total) * 100;
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label, 
            style: TextStyle(
              color: color, 
              fontWeight: FontWeight.bold, 
              fontSize: 12
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: count / total,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${percentage.toStringAsFixed(0)}%', 
            style: const TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBmiDistribution() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  sections: _bmiDistribution,
                  borderData: FlBorderData(show: false),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBmiLegend('Underweight', Colors.blue),
              const SizedBox(height: 8),
              _buildBmiLegend('Normal', Colors.green),
              const SizedBox(height: 8),
              _buildBmiLegend('Overweight', Colors.orange),
              const SizedBox(height: 8),
              _buildBmiLegend('Obese', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBmiLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color, 
            borderRadius: BorderRadius.circular(3)
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label, 
          style: const TextStyle(
            fontSize: 12, 
            color: Color(0xFF4B5563)
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Manage Users', 
                Icons.people, 
                Colors.green, 
                () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => const UserManagementScreen()
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Manage Foods', 
                Icons.restaurant, 
                Colors.blue, 
                () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => const MealManagementScreen()
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Manage Workouts', 
                Icons.fitness_center, 
                Colors.orange, 
                () {
                  // ✅ FIXED: Uncommented and working!
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => const WorkoutManagementScreen()
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'View Reports', 
                Icons.analytics, 
                Colors.purple, 
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label, 
                style: TextStyle(
                  color: color, 
                  fontWeight: FontWeight.bold, 
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}