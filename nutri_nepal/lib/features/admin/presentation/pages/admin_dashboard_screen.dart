import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nutri_nepal/app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/services/hive/hive_service.dart';
import 'package:nutri_nepal/core/widgets/app_logo.dart';
import 'package:nutri_nepal/features/admin/domain/entities/admin_entity.dart';
import 'package:nutri_nepal/features/admin/presentation/pages/meal_management_screen.dart';
import 'package:nutri_nepal/features/admin/presentation/pages/user_management_screen.dart';
import 'package:nutri_nepal/features/admin/presentation/pages/workout_management_screen.dart';
import 'package:nutri_nepal/features/admin/presentation/providers/admin_provider.dart';
import 'package:nutri_nepal/features/auth/presentation/pages/login_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  AdminDashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final stats = await ref.read(adminProvider.notifier).loadDashboardStats();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout Admin'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    await ref.read(adminProvider.notifier).logout();
    await ref.read(hiveServiceProvider).logoutUser();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 64,
        title: Row(
          children: [
            const AppLogo(fullLogo: false, size: 42),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Admin Dashboard',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showLogoutDialog,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
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
        color: AppColors.white,
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = _stats;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(
          '${stats?.totalUsers ?? 0}',
          'Total Users',
          Colors.green,
          Icons.people,
        ),
        _buildStatCard(
          '${stats?.totalFoodItems ?? 0}',
          'Total Foods',
          Colors.blue,
          Icons.restaurant,
        ),
        _buildStatCard(
          '${stats?.totalWorkouts ?? 0}',
          'Total Workouts',
          Colors.orange,
          Icons.fitness_center,
        ),
        _buildStatCard(
          '${stats?.activeToday ?? 0}',
          'Active Today',
          Colors.purple,
          Icons.visibility,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
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
              color: AppColors.grey,
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
    final goals =
        _stats?.fitnessGoals ??
        const {
          'Weight Loss': 0,
          'Muscle Gain': 0,
          'Endurance': 0,
          'Maintenance': 0,
        };
    var total = goals.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) total = 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          _buildGoalRow(
            'Weight Loss',
            Colors.red,
            goals['Weight Loss'] ?? 0,
            total,
          ),
          const SizedBox(height: 12),
          _buildGoalRow(
            'Muscle Gain',
            Colors.green,
            goals['Muscle Gain'] ?? 0,
            total,
          ),
          const SizedBox(height: 12),
          _buildGoalRow(
            'Endurance',
            Colors.blue,
            goals['Endurance'] ?? 0,
            total,
          ),
          const SizedBox(height: 12),
          _buildGoalRow(
            'Maintenance',
            Colors.orange,
            goals['Maintenance'] ?? 0,
            total,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalRow(String label, Color color, int count, int total) {
    final percentage = (count / total) * 100;
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildBmiDistribution() {
    final distribution = _stats?.bmiDistribution ?? const {};
    final underweight = distribution['underweight'] ?? 0;
    final normal = distribution['normal'] ?? 0;
    final overweight = distribution['overweight'] ?? 0;
    final obese = distribution['obese'] ?? 0;
    var total = underweight + normal + overweight + obese;
    if (total == 0) total = 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  sections: [
                    _bmiSection(underweight, total, Colors.blue),
                    _bmiSection(normal, total, Colors.green),
                    _bmiSection(overweight, total, Colors.orange),
                    _bmiSection(obese, total, Colors.red),
                  ],
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

  PieChartSectionData _bmiSection(int count, int total, Color color) {
    return PieChartSectionData(
      value: count.toDouble(),
      color: color,
      title: '${(count / total * 100).toStringAsFixed(0)}%',
      radius: 50,
      titleStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
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
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
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
                      builder: (_) => const UserManagementScreen(),
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
                      builder: (_) => const MealManagementScreen(),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WorkoutManagementScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Refresh Stats',
                Icons.analytics,
                Colors.purple,
                _loadData,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
      ],
    );
  }
}
