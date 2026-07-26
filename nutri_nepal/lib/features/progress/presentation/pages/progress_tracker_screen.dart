import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
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
  List<ProgressPointEntity> _weightHistory = [];
  double _startingWeight = 0;
  double _currentWeight = 0;
  HealthProfileEntity? _currentProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadProgressData();
      }
    });
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);

    try {
      final profile = await ref
          .read(healthProfileProvider.notifier)
          .loadProfile();
      if (profile != null) {
        setState(() {
          _currentWeight = profile.weight;
          _startingWeight = profile.weight;
          _currentProfile = profile;
        });
      } else {
        setState(() => _isLoading = false);
        return;
      }

      final progressState = await ref.read(progressProvider.notifier).load();
      if (progressState != null && mounted) {
        final startWeight = progressState.summary?.startWeight;
        final currentWeight = progressState.summary?.currentWeight;
        setState(() {
          if (startWeight != null) _startingWeight = startWeight;
          if (currentWeight != null) _currentWeight = currentWeight;
          _weightHistory = progressState.calorieHistory;
          _errorMessage = null;
          _isLoading = false;
        });
      } else if (mounted) {
        final providerState = ref.read(progressProvider);
        setState(() {
          _errorMessage = providerState.error?.toString() ?? 'No data yet';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logWeight() async {
    if (_currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your health profile first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final weightController = TextEditingController(
      text: _currentWeight > 0 ? _currentWeight.toString() : '',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Log Your Weight',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1B4332),
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.scale_outlined,
                  color: Color(0xFF1B4332),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final weight = double.tryParse(weightController.text);
                  if (weight != null) {
                    try {
                      await ref
                          .read(healthProfileProvider.notifier)
                          .saveProfile(
                            _currentProfile!.copyWith(weight: weight),
                          );
                      final saved = await ref
                          .read(progressProvider.notifier)
                          .addProgressEntry(weight);
                      if (!saved) {
                        throw Exception('Could not save progress entry');
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _loadProgressData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Weight logged successfully!'),
                          backgroundColor: Color(0xFF1B4332),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid number'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Weight',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get _weightChange =>
      _currentWeight > 0 ? _currentWeight - _startingWeight : 0;
  String get _weightChangeText {
    final change = _weightChange;
    if (change.abs() < 0.05) return '0.0 kg change';
    if (change < 0) return '${change.abs().toStringAsFixed(1)} kg lost';
    return '${change.toStringAsFixed(1)} kg gained';
  }

  String get _weightChangeSubtitle {
    final change = _weightChange;
    if (change.abs() < 0.05) return 'No change since start';
    return 'Since your first logged weight';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(refreshProvider, (previous, next) {
      _loadProgressData();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Progress Tracker',
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
            onPressed: _loadProgressData,
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
              onRefresh: _loadProgressData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Current',
                            '${_currentWeight.toStringAsFixed(1)} kg',
                            Icons.scale_outlined,
                            const Color(0xFF1B4332),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Starting',
                            '${_startingWeight.toStringAsFixed(1)} kg',
                            Icons.flag_outlined,
                            const Color(0xFFB85C00),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                            'PROGRESS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.2,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _weightChangeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _weightChangeSubtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'Weight History (Last 30 Days)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _weightHistory.isEmpty
                          ? _buildEmptyProgressState()
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 5,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >=
                                            _weightHistory.length) {
                                          return const Text('');
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            _chartLabel(
                                              _weightHistory[value.toInt()],
                                            ),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF6B7280),
                                              fontFamily: 'OpenSans',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minY: _minChartY,
                                maxY: _maxChartY,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _weightHistory.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final data = entry.value;
                                      return FlSpot(
                                        index.toDouble(),
                                        data.weight,
                                      );
                                    }).toList(),
                                    isCurved: true,
                                    color: const Color(0xFF1B4332),
                                    barWidth: 3,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                                radius: 4,
                                                color: Colors.white,
                                                strokeWidth: 2,
                                                strokeColor: const Color(
                                                  0xFF1B4332,
                                                ),
                                              ),
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0x401B4332),
                                          Color(0x001B4332),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logWeight,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'Log Weight',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB85C00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  double get _minChartY {
    if (_weightHistory.isEmpty) return 0;
    final weights = _weightHistory
        .map((item) => item.weight)
        .where((weight) => weight > 0)
        .toList();
    if (weights.isEmpty) return 0;
    final min = weights.reduce((a, b) => a < b ? a : b);
    return (min - 2).clamp(0, double.infinity).toDouble();
  }

  double get _maxChartY {
    if (_weightHistory.isEmpty) return 10;
    final weights = _weightHistory
        .map((item) => item.weight)
        .where((weight) => weight > 0)
        .toList();
    if (weights.isEmpty) return 10;
    final max = weights.reduce((a, b) => a > b ? a : b);
    return max + 2;
  }

  Widget _buildEmptyProgressState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1B4332).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.show_chart,
              color: Color(0xFF1B4332),
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No weight history yet',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add your weight regularly to see progress here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontFamily: 'OpenSans',
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _logWeight,
            child: const Text('Add first entry'),
          ),
        ],
      ),
    );
  }

  String _chartLabel(ProgressPointEntity point) {
    if (point.label.length >= 7) return point.label.substring(5);
    if (point.date == null) return '';
    return '${point.date!.month.toString().padLeft(2, '0')}-${point.date!.day.toString().padLeft(2, '0')}';
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
              'Progress could not load',
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
              onPressed: _loadProgressData,
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

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
              fontFamily: 'OpenSans',
            ),
          ),
        ],
      ),
    );
  }
}
