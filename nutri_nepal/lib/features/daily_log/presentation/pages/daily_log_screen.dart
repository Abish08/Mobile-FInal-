import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/providers/refresh_provider.dart';
import 'package:nutri_nepal/features/daily_log/domain/entities/daily_log_entity.dart';
import 'package:nutri_nepal/features/daily_log/presentation/providers/daily_log_provider.dart';
import 'package:nutri_nepal/features/health_profile/presentation/providers/health_profile_provider.dart';

class DailyLogScreen extends ConsumerStatefulWidget {
  const DailyLogScreen({super.key});

  @override
  ConsumerState<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends ConsumerState<DailyLogScreen> {
  bool _isLoading = true;
  double _targetCalories = 2500;
  double _consumedCalories = 0;
  double _burnedCalories = 0;

  List<DailyLogItemEntity> _foodLogs = [];
  List<DailyLogItemEntity> _workoutLogs = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDailyData();
      }
    });
  }

  Future<void> _loadDailyData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final profileData = await ref
          .read(healthProfileProvider.notifier)
          .loadProfile();
      if (profileData != null && mounted) {
        setState(() {
          _targetCalories = (profileData.targetCalories ?? 2500).toDouble();
        });
      }

      final dailyLog = await ref.read(dailyLogProvider.notifier).loadDailyLog();
      if (dailyLog != null && mounted) {
        setState(() {
          _foodLogs = dailyLog.foodLogs;
          _workoutLogs = dailyLog.workoutLogs;
          _consumedCalories = dailyLog.consumedCalories;
          _burnedCalories = dailyLog.burnedCalories;
          _errorMessage = null;
        });
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  double get _remainingCalories =>
      _targetCalories - _consumedCalories + _burnedCalories;
  double get _adjustedGoal => _targetCalories + _burnedCalories;
  double get _progress => _targetCalories > 0
      ? (_consumedCalories / _targetCalories).clamp(0.0, 1.0)
      : 0.0;

  String get _formattedDate {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Today, ${now.day} ${months[now.month - 1]}';
  }

  String? _logId(DailyLogItemEntity log) {
    return log.id;
  }

  Future<void> _deleteLog(DailyLogItemEntity log, bool isWorkout) async {
    final id = _logId(log);
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not find this log entry'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove log?'),
        content: Text('Delete "${log.title}" from today\'s log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final deleted = await ref
          .read(dailyLogProvider.notifier)
          .deleteLog(id: id, isWorkout: isWorkout);
      if (!deleted) {
        throw Exception('Delete failed');
      }
      await _loadDailyData();
      ref.read(refreshProvider.notifier).refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${log.title} removed from log'),
          backgroundColor: const Color(0xFF1B4332),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for refresh triggers and re-fetch data
    ref.listen(refreshProvider, (previous, next) {
      _loadDailyData();
    });

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
            onPressed: _loadDailyData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B4332)),
            )
          : _errorMessage != null
          ? _buildErrorState(_errorMessage!)
          : RefreshIndicator(
              onRefresh: _loadDailyData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF1B4332,
                            ).withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TODAY',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.2,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _remainingCalories >= 0
                                ? '${_remainingCalories.round()} kcal'
                                : '${_remainingCalories.abs().round()} kcal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          Text(
                            _remainingCalories >= 0
                                ? 'remaining from your adjusted goal'
                                : 'over your adjusted goal',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _formattedDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFB85C00),
                              ),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCalorieRow(
                            'Target',
                            '${_targetCalories.round()} kcal',
                          ),
                          _buildCalorieRow(
                            'Consumed',
                            '${_consumedCalories.round()} kcal',
                          ),
                          _buildCalorieRow(
                            'Activity',
                            '+${_burnedCalories.round()} kcal',
                          ),
                          _buildCalorieRow(
                            'Adjusted goal',
                            '${_adjustedGoal.round()} kcal',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'Meals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_foodLogs.isEmpty)
                      _buildEmptyState(
                        'No meals logged today',
                        'Add meals from the Meals tab to track your intake.',
                        Icons.restaurant_menu,
                      )
                    else
                      ..._foodLogs.map(
                        (log) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildLogItem(
                            Icons.restaurant_outlined,
                            log.title,
                            log.subtitle,
                            Colors.orange,
                            onDelete: () => _deleteLog(log, false),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    const Text(
                      'Exercises',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_workoutLogs.isEmpty)
                      _buildEmptyState(
                        'No exercises logged today',
                        'Complete workouts to track activity calories.',
                        Icons.fitness_center_outlined,
                      )
                    else
                      ..._workoutLogs.map(
                        (log) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildLogItem(
                            Icons.fitness_center_outlined,
                            log.title,
                            log.subtitle,
                            const Color(0xFF1B4332),
                            onDelete: () => _deleteLog(log, true),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCalorieRow(String label, String value) {
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

  Widget _buildLogItem(
    IconData icon,
    String title,
    String subtitle,
    Color color, {
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              color: color.withValues(alpha: 0.1),
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
                    fontWeight: FontWeight.w600,
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
          PopupMenuButton<String>(
            tooltip: 'Log options',
            icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
            onSelected: (value) {
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontFamily: 'OpenSans',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 36),
            const SizedBox(height: 12),
            const Text(
              'Daily log could not load',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontFamily: 'OpenSans',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDailyData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4332),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
