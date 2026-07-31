import 'package:flutter/material.dart';
import 'package:nutri_nepal/app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nutri_nepal/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:nutri_nepal/features/workouts/domain/entities/workout_entity.dart';
import 'package:nutri_nepal/features/workouts/presentation/providers/workout_provider.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  List<UserWorkout> _workouts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Strength',
    'Cardio',
    'Flexibility',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchWorkouts();
      }
    });
  }

  Future<void> _fetchWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final workoutState = await ref.read(workoutProvider.notifier).load();
      if (workoutState != null && mounted) {
        setState(() {
          _workouts = workoutState.workouts;
          _errorMessage = null;
          _isLoading = false;
        });
      } else if (mounted) {
        final providerState = ref.read(workoutProvider);
        setState(() {
          _errorMessage =
              providerState.error?.toString() ?? 'No workouts found';
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

  List<UserWorkout> get _filteredWorkouts {
    if (_selectedCategory == 'All') return _workouts;
    return _workouts
        .where(
          (w) => w.category.toLowerCase() == _selectedCategory.toLowerCase(),
        )
        .toList();
  }

  int _categoryCount(String category) {
    if (category == 'All') return _workouts.length;
    return _workouts
        .where((w) => w.category.toLowerCase() == category.toLowerCase())
        .length;
  }

  Future<void> _launchYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return const Color(0xFFB85C00);
      case 'cardio':
        return AppColors.primaryOrange;
      case 'flexibility':
      case 'yoga':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  Future<void> _logWorkout(UserWorkout workout) async {
    final authState = ref.read(authViewModelProvider);
    final userId = authState.user?.userId;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final logged = await ref
          .read(workoutProvider.notifier)
          .logWorkout(workout);
      if (logged) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${workout.name} logged successfully!'),
              backgroundColor: AppColors.primaryOrange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          _fetchWorkouts();
        }
      } else {
        throw Exception(
          ref.read(workoutProvider).error ?? 'Could not log this workout',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Workouts',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryOrange),
            onPressed: _fetchWorkouts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          : _errorMessage != null
          ? _buildErrorWorkoutState(_errorMessage!)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: _buildPlanHeader(),
                ),
                Container(
                  height: 64,
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      final count = _categoryCount(category);
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          constraints: const BoxConstraints(minWidth: 76),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryOrange
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryOrange
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.grey,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$count',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _filteredWorkouts.isEmpty
                      ? _buildEmptyWorkoutState()
                      : RefreshIndicator(
                          onRefresh: _fetchWorkouts,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            itemCount: _filteredWorkouts.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) =>
                                _buildEnhancedWorkoutCard(
                                  _filteredWorkouts[index],
                                  index,
                                ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPlanHeader() {
    final activeCount = _workouts.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Today\'s Strength Session',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'ACTIVE',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$activeCount workouts ready. Choose a focus and log your session.',
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 13,
            height: 1.4,
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedWorkoutCard(UserWorkout workout, int index) {
    final categoryColor = _getCategoryColor(workout.category);
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) => Transform.translate(
        offset: Offset(0, 50 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  workout.thumbnail != null
                      ? Image.network(
                          workout.thumbnail!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        workout.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                  if (workout.youtubeUrl != null &&
                      workout.youtubeUrl!.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _launchYouTube(workout.youtubeUrl!),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          workout.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      Icon(
                        Icons.fitness_center,
                        size: 20,
                        color: categoryColor,
                      ),
                    ],
                  ),
                  if (workout.description != null &&
                      workout.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      workout.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (workout.difficulty != null &&
                          workout.difficulty!.isNotEmpty)
                        _buildStatChip(
                          Icons.trending_up_outlined,
                          workout.difficulty!,
                          categoryColor,
                        ),
                      if (workout.sets != null && workout.reps != null)
                        _buildStatChip(
                          Icons.repeat,
                          '${workout.sets} sets x ${workout.reps} reps',
                          const Color(0xFF2563EB),
                        ),
                      if (workout.rest != null && workout.rest!.isNotEmpty)
                        _buildStatChip(
                          Icons.timer_outlined,
                          'Rest ${workout.rest}',
                          AppColors.grey,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatChip(
                        Icons.access_time_outlined,
                        '${_workoutDuration(workout)} min',
                        Colors.orange,
                      ),
                      if (workout.caloriesBurned != null) ...[
                        _buildStatChip(
                          Icons.local_fire_department_outlined,
                          '${workout.caloriesBurned} kcal',
                          Colors.red,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showWorkoutDetails(workout),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryOrange,
                            side: const BorderSide(
                              color: AppColors.primaryOrange,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _logWorkout(workout),
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB85C00),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      decoration: const BoxDecoration(color: Color(0xFFEFF6F1)),
      child: const Icon(
        Icons.fitness_center_outlined,
        size: 64,
        color: AppColors.primaryOrange,
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkoutState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.fitness_center_outlined,
                color: AppColors.primaryOrange,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No workouts found',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try another focus or refresh the catalog.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 13,
                fontFamily: 'OpenSans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWorkoutState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 36),
            const SizedBox(height: 12),
            const Text(
              'Workouts could not load',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 13,
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchWorkouts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutDetails(UserWorkout workout) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.appBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 20),
            Text(
              workout.name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${workout.category} - ${workout.difficulty ?? 'General'}',
              style: const TextStyle(
                color: AppColors.grey,
                fontFamily: 'OpenSans',
              ),
            ),
            if (workout.description != null &&
                workout.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                workout.description!,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  height: 1.4,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
            const SizedBox(height: 18),
            _buildDetailRow('Duration', '${_workoutDuration(workout)} min'),
            if (workout.caloriesBurned != null)
              _buildDetailRow('Calories', '${workout.caloriesBurned} kcal'),
            if (workout.sets != null && workout.reps != null)
              _buildDetailRow('Sets', '${workout.sets} x ${workout.reps} reps'),
            if (workout.rest != null && workout.rest!.isNotEmpty)
              _buildDetailRow('Rest', workout.rest!),
            if (workout.equipment != null && workout.equipment!.isNotEmpty)
              _buildDetailRow('Equipment', workout.equipment!),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _logWorkout(workout);
                },
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Complete workout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB85C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _workoutDuration(UserWorkout workout) {
    final parsed = int.tryParse(workout.duration ?? '');
    if (parsed == null || parsed <= 0) return 30;
    return parsed;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.grey,
              fontFamily: 'OpenSans',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
