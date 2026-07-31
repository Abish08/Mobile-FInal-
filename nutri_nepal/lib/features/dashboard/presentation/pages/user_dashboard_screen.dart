import 'package:flutter/material.dart';
import 'package:nutri_nepal/app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/providers/refresh_provider.dart';
import 'package:nutri_nepal/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:nutri_nepal/features/daily_log/domain/entities/daily_log_entity.dart';
import 'package:nutri_nepal/features/daily_log/presentation/providers/daily_log_provider.dart';
import 'package:nutri_nepal/features/health_profile/domain/entities/health_profile_entity.dart';
import 'package:nutri_nepal/features/health_profile/presentation/providers/health_profile_provider.dart';

class UserDashboardScreen extends ConsumerStatefulWidget {
  final ValueChanged<int>? onSelectTab;

  const UserDashboardScreen({super.key, this.onSelectTab});

  @override
  ConsumerState<UserDashboardScreen> createState() =>
      _UserDashboardScreenState();
}

class _UserDashboardScreenState extends ConsumerState<UserDashboardScreen> {
  HealthProfileEntity? _profile;
  DailyLogEntity? _dailyLog;
  String _firstName = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchDashboardData();
      }
    });
  }

  int _toInt(dynamic val) =>
      val == null ? 0 : (val is int ? val : val.toDouble().toInt());
  double _toDouble(dynamic val) =>
      val == null ? 0.0 : (val is double ? val : val.toDouble());

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final profile = await ref
          .read(healthProfileProvider.notifier)
          .loadProfile();
      final dailyLog = await ref.read(dailyLogProvider.notifier).loadDailyLog();
      final authUser = ref.read(authViewModelProvider).user;

      if (profile != null && mounted) {
        setState(() {
          _profile = profile;
          _dailyLog = dailyLog;
          _firstName = authUser?.firstName ?? 'User';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _calculateBMI(double weight, double heightCm) {
    final heightM = heightCm / 100;
    if (weight <= 0 || heightM <= 0) return double.nan;
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
    ref.listen(refreshProvider, (previous, next) {
      _fetchDashboardData();
    });

    ref.watch(authViewModelProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );
    }

    final profile = _profile;
    final dailyLog = _dailyLog;

    final totalCalories = _toInt(dailyLog?.consumedCalories);
    final burnedCalories = _toInt(dailyLog?.burnedCalories);
    final totalProtein = _toDouble(dailyLog?.protein);
    final totalCarbs = _toDouble(dailyLog?.carbs);
    final totalFats = _toDouble(dailyLog?.fats);

    final macros = profile?.macros;
    final proteinGoal = _toDouble(macros?['protein']);
    final carbsGoal = _toDouble(macros?['carbs']);
    final fatsGoal = _toDouble(macros?['fats']);
    final weight = _toDouble(profile?.weight);
    final height = _toDouble(profile?.height);
    final bmi = _calculateBMI(weight, height);
    final calorieGoal = _toInt(profile?.targetCalories ?? 2500);
    final adjustedGoal = calorieGoal + burnedCalories;
    final remainingCalories = adjustedGoal - totalCalories;
    final goalProgress = calorieGoal > 0
        ? (totalCalories / calorieGoal).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'NutriNepal',
          style: TextStyle(
            color: AppColors.primaryOrange,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Namaste, $_firstName',
                style: const TextStyle(
                  color: AppColors.primaryOrange,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                calorieGoal > 0
                    ? 'You\'re ${(goalProgress * 100).toStringAsFixed(0)}% towards your food goal today'
                    : 'Complete your health profile to personalize your goals',
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                  fontFamily: 'OpenSans',
                ),
              ),
              const SizedBox(height: 24),

              _buildCaloriesCard(
                consumed: totalCalories,
                burned: burnedCalories,
                goal: calorieGoal,
                adjustedGoal: adjustedGoal,
                remaining: remainingCalories,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildMacroCard(
                      'Protein',
                      totalProtein,
                      proteinGoal,
                      const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroCard(
                      'Carbs',
                      totalCarbs,
                      carbsGoal,
                      const Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroCard(
                      'Fats',
                      totalFats,
                      fatsGoal,
                      const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      Icons.restaurant_outlined,
                      'Meal',
                      const Color(0xFFB85C00),
                      () => widget.onSelectTab?.call(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAction(
                      Icons.fitness_center_outlined,
                      'Workout',
                      AppColors.primaryOrange,
                      () => widget.onSelectTab?.call(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAction(
                      Icons.scale_outlined,
                      'Weight',
                      const Color(0xFF2563EB),
                      () => widget.onSelectTab?.call(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const Text(
                'Today\'s Updates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 16),

              _buildUpdateItem(
                Icons.edit_note_outlined,
                'Daily log',
                totalCalories > 0 || burnedCalories > 0
                    ? '$totalCalories kcal eaten, $burnedCalories kcal burned'
                    : 'No meals or workouts logged yet today',
                const Color(0xFFB85C00),
                () => widget.onSelectTab?.call(3),
              ),
              const SizedBox(height: 12),
              _buildUpdateItem(
                Icons.show_chart_outlined,
                'Progress tracker',
                bmi.isFinite && bmi > 0
                    ? 'BMI ${bmi.toStringAsFixed(1)} from your saved profile'
                    : 'Add height and weight to unlock body metrics',
                AppColors.primaryOrange,
                () => widget.onSelectTab?.call(4),
              ),
              const SizedBox(height: 28),

              const Text(
                'Body Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 16),
              _buildBMICard(bmi),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMICard(double bmi) {
    final hasValidBmi = bmi.isFinite && bmi > 0;
    final category = hasValidBmi ? _getBMICategory(bmi) : 'Complete profile';
    final color = hasValidBmi ? _getBMIColor(bmi) : AppColors.grey;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Body mass index',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Based on your saved profile details',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
              TextButton(
                onPressed: () => widget.onSelectTab?.call(5),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasValidBmi ? bmi.toStringAsFixed(1) : '--',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Montserrat',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          if (hasValidBmi) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (bmi / 40).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCaloriesCard({
    required int consumed,
    required int burned,
    required int goal,
    required int adjustedGoal,
    required int remaining,
  }) {
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.accentOrange],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Goal',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.2,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$consumed / $goal kcal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          Text(
            remaining >= 0
                ? '$remaining kcal remaining'
                : '${remaining.abs()} kcal over target',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'OpenSans',
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFB85C00),
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 14),
          _buildCaloriesBreakdown('Consumed', '$consumed kcal'),
          _buildCaloriesBreakdown('Daily target', '$goal kcal'),
          _buildCaloriesBreakdown('Activity', '+$burned kcal'),
          _buildCaloriesBreakdown('Adjusted goal', '$adjustedGoal kcal'),
        ],
      ),
    );
  }

  Widget _buildCaloriesBreakdown(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'OpenSans',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroCard(String label, double value, double goal, Color color) {
    final hasGoal = goal > 0;
    final progress = hasGoal ? (value / goal).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Icon(
                    label == 'Protein'
                        ? Icons.fitness_center_outlined
                        : label == 'Carbs'
                        ? Icons.bakery_dining_outlined
                        : Icons.water_drop_outlined,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${value.toStringAsFixed(0)}g',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Montserrat',
            ),
          ),
          if (hasGoal)
            Text(
              '/ ${goal.toStringAsFixed(0)}g',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.grey,
                fontFamily: 'OpenSans',
              ),
            )
          else
            const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
              fontFamily: 'OpenSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
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
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
