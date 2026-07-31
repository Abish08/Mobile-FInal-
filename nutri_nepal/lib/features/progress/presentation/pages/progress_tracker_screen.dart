import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/app/theme/app_colors.dart';
import 'package:nutri_nepal/core/providers/refresh_provider.dart';
import 'package:nutri_nepal/features/health_profile/domain/entities/health_profile_entity.dart';
import 'package:nutri_nepal/features/health_profile/presentation/providers/health_profile_provider.dart';
import 'package:nutri_nepal/features/progress/domain/entities/progress_entity.dart';
import 'package:nutri_nepal/features/progress/presentation/providers/progress_provider.dart';

class ProgressTrackerScreen extends ConsumerStatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
  ConsumerState<ProgressTrackerScreen> createState() =>
      _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends ConsumerState<ProgressTrackerScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  ProgressState _progress = const ProgressState.empty();
  HealthProfileEntity? _profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadProgressData();
    });
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await ref
          .read(healthProfileProvider.notifier)
          .loadProfile();
      final progressState = await ref.read(progressProvider.notifier).load();

      if (!mounted) return;
      if (progressState == null) {
        setState(() {
          _profile = profile;
          _errorMessage =
              ref.read(progressProvider).error?.toString() ??
              'No progress data yet';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _profile = profile;
        _progress = progressState;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logWeight() async {
    final profile = _profile;
    if (profile == null) {
      _showSnack('Please complete your health profile first', AppColors.error);
      return;
    }

    final weightController = TextEditingController(
      text: _currentWeight > 0 ? _currentWeight.toStringAsFixed(1) : '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Log Weight',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: const Icon(
                  Icons.monitor_weight_outlined,
                  color: AppColors.primaryOrange,
                ),
                filled: true,
                fillColor: AppColors.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final weight = double.tryParse(weightController.text.trim());
                  if (weight == null || weight <= 0) {
                    _showSnack('Please enter a valid weight', AppColors.error);
                    return;
                  }

                  try {
                    await ref
                        .read(healthProfileProvider.notifier)
                        .saveProfile(profile.copyWith(weight: weight));
                    final saved = await ref
                        .read(progressProvider.notifier)
                        .addProgressEntry(weight);
                    if (!saved) throw Exception('Could not save progress');
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    await _loadProgressData();
                    _showSnack('Weight logged successfully', AppColors.success);
                  } catch (e) {
                    if (!context.mounted) return;
                    _showSnack('Error: $e', AppColors.error);
                  }
                },
                child: const Text('Save Weight'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double get _currentWeight =>
      _profile?.weight ?? _progress.summary?.currentWeight ?? 0;
  double get _startingWeight =>
      _progress.summary?.startWeight ?? _profile?.weight ?? 0;
  double get _weightChange => _currentWeight - _startingWeight;
  double get _heightCm => _profile?.height ?? 0;
  double get _bmi {
    final heightM = _heightCm / 100;
    if (_currentWeight <= 0 || heightM <= 0) return 0;
    return _currentWeight / (heightM * heightM);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(refreshProvider, (previous, next) => _loadProgressData());

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Progress Tracker',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryOrange),
            onPressed: _loadProgressData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          : _errorMessage != null
          ? _ErrorState(message: _errorMessage!, onRetry: _loadProgressData)
          : RefreshIndicator(
              onRefresh: _loadProgressData,
              color: AppColors.primaryOrange,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  _Header(onLogWeight: _logWeight),
                  const SizedBox(height: 16),
                  _StatsGrid(
                    calorieHistory: _progress.calorieHistory,
                    workoutHistory: _progress.workoutHistory,
                  ),
                  const SizedBox(height: 16),
                  _CalorieTrendCard(points: _progress.calorieHistory),
                  const SizedBox(height: 16),
                  _WorkoutTrendCard(points: _progress.workoutHistory),
                  const SizedBox(height: 16),
                  _RecentHistoryCard(
                    calorieHistory: _progress.calorieHistory,
                    workoutHistory: _progress.workoutHistory,
                  ),
                  const SizedBox(height: 16),
                  _BodyMetricsCard(
                    currentWeight: _currentWeight,
                    startingWeight: _startingWeight,
                    weightChange: _weightChange,
                    bmi: _bmi,
                    onLogWeight: _logWeight,
                  ),
                ],
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onLogWeight;

  const _Header({required this.onLogWeight});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR PROGRESS',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Real trends from your logs',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Calories, macros, workouts, and body progress over time.',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 13,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filled(
          onPressed: onLogWeight,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: AppColors.white,
          ),
          icon: const Icon(Icons.add),
          tooltip: 'Log weight',
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<ProgressPointEntity> calorieHistory;
  final List<ProgressPointEntity> workoutHistory;

  const _StatsGrid({
    required this.calorieHistory,
    required this.workoutHistory,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = calorieHistory.sumBy((point) => point.calories);
    final averageCalories = calorieHistory.isEmpty
        ? 0
        : totalCalories / calorieHistory.length;
    final workoutBurn = workoutHistory.sumBy((point) => point.calories);
    final workoutMinutes = workoutHistory.sumBy((point) => point.duration);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _MetricCard(
          label: 'Total Calories',
          value: totalCalories.round().toString(),
          unit: 'kcal',
          icon: Icons.local_fire_department_outlined,
        ),
        _MetricCard(
          label: 'Average Calories',
          value: averageCalories.round().toString(),
          unit: 'kcal',
          icon: Icons.speed_outlined,
        ),
        _MetricCard(
          label: 'Workout Burn',
          value: workoutBurn.round().toString(),
          unit: 'kcal',
          icon: Icons.fitness_center,
        ),
        _MetricCard(
          label: 'Workout Minutes',
          value: workoutMinutes.round().toString(),
          unit: 'min',
          icon: Icons.timer_outlined,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primaryOrange, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      unit,
                      style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 11,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalorieTrendCard extends StatelessWidget {
  final List<ProgressPointEntity> points;

  const _CalorieTrendCard({required this.points});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Calorie Intake Trend',
      subtitle: 'Daily calories and macros from food logs.',
      height: 280,
      legend: const [
        _LegendItem('Calories', AppColors.primaryOrange),
        _LegendItem('Carbs', AppColors.success),
        _LegendItem('Protein', AppColors.info),
        _LegendItem('Fats', AppColors.warning),
      ],
      child: points.isEmpty
          ? const _EmptyChart(message: 'No meal logs yet')
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: _maxY(points, [
                  (p) => p.calories,
                  (p) => p.carbs,
                  (p) => p.protein,
                  (p) => p.fats,
                ]),
                gridData: _grid,
                borderData: FlBorderData(show: false),
                titlesData: _titles(points),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipColor: (_) => AppColors.surfaceSoft,
                    getTooltipItems: (spots) => spots.map((spot) {
                      return LineTooltipItem(
                        _compactValue(spot.y),
                        const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  _line(points, (p) => p.calories, AppColors.primaryOrange),
                  _line(points, (p) => p.carbs, AppColors.success),
                  _line(points, (p) => p.protein, AppColors.info),
                  _line(points, (p) => p.fats, AppColors.warning),
                ],
              ),
            ),
    );
  }
}

class _WorkoutTrendCard extends StatelessWidget {
  final List<ProgressPointEntity> points;

  const _WorkoutTrendCard({required this.points});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Workout Duration Trend',
      subtitle: 'Workout minutes and calories burned from exercise logs.',
      height: 280,
      legend: const [
        _LegendItem('Minutes', AppColors.primaryOrange),
        _LegendItem('Calories burned', AppColors.info),
      ],
      child: points.isEmpty
          ? const _EmptyChart(message: 'No workout logs yet')
          : BarChart(
              BarChartData(
                minY: 0,
                maxY: _maxY(points, [(p) => p.duration, (p) => p.calories]),
                gridData: _grid,
                borderData: FlBorderData(show: false),
                titlesData: _titles(points),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipColor: (_) => AppColors.surfaceSoft,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final unit = rodIndex == 0 ? 'min' : 'kcal';
                      return BarTooltipItem(
                        '${_compactValue(rod.toY)} $unit',
                        const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: points.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.duration,
                        width: 10,
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      BarChartRodData(
                        toY: entry.value.calories,
                        width: 10,
                        color: AppColors.info,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;
  final Widget child;
  final List<_LegendItem> legend;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.height,
    required this.child,
    required this.legend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 12,
              fontFamily: 'OpenSans',
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(height: height, child: child),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 6, children: legend),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 11,
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }
}

class _RecentHistoryCard extends StatelessWidget {
  final List<ProgressPointEntity> calorieHistory;
  final List<ProgressPointEntity> workoutHistory;

  const _RecentHistoryCard({
    required this.calorieHistory,
    required this.workoutHistory,
  });

  @override
  Widget build(BuildContext context) {
    final latestFood = calorieHistory.lastOrNull;
    final latestWorkout = workoutHistory.lastOrNull;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent History',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 12),
          _HistoryRow(
            label: 'Latest calorie entry',
            value: latestFood == null
                ? 'No meal log'
                : '${latestFood.label} - ${latestFood.calories.round()} kcal',
            color: AppColors.primaryOrange,
          ),
          const SizedBox(height: 8),
          _HistoryRow(
            label: 'Latest workout entry',
            value: latestWorkout == null
                ? 'No workout log'
                : '${latestWorkout.label} - ${latestWorkout.duration.round()} min',
            color: AppColors.info,
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HistoryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyMetricsCard extends StatelessWidget {
  final double currentWeight;
  final double startingWeight;
  final double weightChange;
  final double bmi;
  final VoidCallback onLogWeight;

  const _BodyMetricsCard({
    required this.currentWeight,
    required this.startingWeight,
    required this.weightChange,
    required this.bmi,
    required this.onLogWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Body Measurements',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'Current',
                  value: currentWeight > 0
                      ? '${currentWeight.toStringAsFixed(1)} kg'
                      : 'N/A',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetric(
                  label: 'Starting',
                  value: startingWeight > 0
                      ? '${startingWeight.toStringAsFixed(1)} kg'
                      : 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: 'Change',
                  value: '${weightChange.toStringAsFixed(1)} kg',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniMetric(
                  label: 'BMI',
                  value: bmi > 0 ? bmi.toStringAsFixed(1) : 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onLogWeight,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryOrange,
              side: const BorderSide(color: AppColors.primaryOrange),
            ),
            icon: const Icon(Icons.monitor_weight_outlined, size: 18),
            label: const Text('Log weight'),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 11,
              fontFamily: 'OpenSans',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;

  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: AppColors.grey, fontFamily: 'OpenSans'),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Progress could not load',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.grey,
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

FlGridData get _grid => FlGridData(
  show: true,
  drawVerticalLine: false,
  getDrawingHorizontalLine: (value) =>
      FlLine(color: AppColors.border.withValues(alpha: 0.6), strokeWidth: 1),
);

FlTitlesData _titles(List<ProgressPointEntity> points) {
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 42,
        interval: null,
        getTitlesWidget: (value, meta) {
          if (value == meta.min || value == meta.max) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              _compactValue(value),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 10,
                fontFamily: 'OpenSans',
              ),
            ),
          );
        },
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        interval: math.max(1, (points.length / 4).ceil()).toDouble(),
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index < 0 || index >= points.length) return const SizedBox();
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _label(points[index]),
              style: const TextStyle(color: AppColors.grey, fontSize: 10),
            ),
          );
        },
      ),
    ),
  );
}

String _compactValue(double value) {
  if (!value.isFinite) return '0';
  final abs = value.abs();
  if (abs >= 1000) {
    final compact = value / 1000;
    return compact == compact.roundToDouble()
        ? '${compact.toStringAsFixed(0)}k'
        : '${compact.toStringAsFixed(1)}k';
  }
  if (abs >= 100) return value.toStringAsFixed(0);
  if (abs >= 10) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1);
}

LineChartBarData _line(
  List<ProgressPointEntity> points,
  double Function(ProgressPointEntity point) valueOf,
  Color color,
) {
  return LineChartBarData(
    spots: points.asMap().entries.map((entry) {
      final y = valueOf(entry.value);
      return FlSpot(entry.key.toDouble(), y.isFinite ? y : 0);
    }).toList(),
    isCurved: true,
    color: color,
    barWidth: 3,
    dotData: const FlDotData(show: false),
    belowBarData: BarAreaData(
      show: true,
      gradient: LinearGradient(
        colors: [color.withValues(alpha: 0.14), color.withValues(alpha: 0.02)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );
}

double _maxY(
  List<ProgressPointEntity> points,
  List<double Function(ProgressPointEntity point)> selectors,
) {
  var maxValue = 0.0;
  for (final point in points) {
    for (final selector in selectors) {
      final value = selector(point);
      if (value.isFinite && value > maxValue) maxValue = value;
    }
  }
  if (maxValue <= 0) return 10;
  return maxValue * 1.2;
}

String _label(ProgressPointEntity point) {
  if (point.label.length >= 10) return point.label.substring(5);
  if (point.date == null) return point.label;
  return '${point.date!.month}/${point.date!.day}';
}

extension on List<ProgressPointEntity> {
  double sumBy(double Function(ProgressPointEntity point) selector) {
    return fold<double>(0, (sum, point) {
      final value = selector(point);
      return sum + (value.isFinite ? value : 0);
    });
  }

  ProgressPointEntity? get lastOrNull => isEmpty ? null : last;
}
