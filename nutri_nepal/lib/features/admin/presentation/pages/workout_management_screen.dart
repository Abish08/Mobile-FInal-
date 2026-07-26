import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/features/admin/domain/entities/admin_entity.dart';
import 'package:nutri_nepal/features/admin/presentation/pages/add_workout_screen.dart';
import 'package:nutri_nepal/features/admin/presentation/providers/admin_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkoutManagementScreen extends ConsumerStatefulWidget {
  const WorkoutManagementScreen({super.key});

  @override
  ConsumerState<WorkoutManagementScreen> createState() =>
      _WorkoutManagementScreenState();
}

class _WorkoutManagementScreenState
    extends ConsumerState<WorkoutManagementScreen> {
  List<AdminWorkout> _workouts = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

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
    final workouts = await ref
        .read(adminProvider.notifier)
        .loadWorkouts(
          category: _selectedFilter != 'All' ? _selectedFilter : '',
        );
    if (!mounted) return;
    setState(() {
      _workouts = workouts ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Workout Management',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: Color(0xFFB85C00),
              size: 30,
            ),
            onPressed: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
              );
              if (res == true) _loadData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: ['All', 'Strength', 'Cardio', 'Flexibility']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (_) {
                          setState(() => _selectedFilter = filter);
                          _loadData();
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _workouts.isEmpty
                ? const Center(
                    child: Text(
                      'No workouts found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _workouts.length,
                    itemBuilder: (context, index) =>
                        _buildCard(_workouts[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(AdminWorkout workout) {
    final imageUrl = workout.thumbnailUrl;
    final youtubeUrl = workout.youtubeUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _placeholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _placeholder(
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                )
              else
                _placeholder(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildChip(workout.category, Colors.green),
                        _buildChip(workout.day.toUpperCase(), Colors.orange),
                        if (workout.difficulty != null)
                          _buildChip(workout.difficulty!, Colors.blue),
                      ],
                    ),
                    if (youtubeUrl != null && youtubeUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () => _launchUrl(youtubeUrl),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Watch on YouTube',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionIcon(Icons.edit, Colors.blue, () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddWorkoutScreen(workoutData: workout),
                      ),
                    );
                    if (res == true) _loadData();
                  }),
                  const SizedBox(height: 4),
                  _buildActionIcon(
                    Icons.delete,
                    Colors.red,
                    () => _deleteWorkout(workout.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceAround,
            children: [
              if (workout.duration != null)
                _buildMetric('Duration', workout.duration!),
              if (workout.caloriesBurned != null)
                _buildMetric('Calories', '${workout.caloriesBurned}'),
              if (workout.equipment != null && workout.equipment!.isNotEmpty)
                _buildMetric('Equipment', workout.equipment!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _placeholder({Widget? child}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child ?? const Icon(Icons.fitness_center, color: Colors.grey),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return SizedBox(
      width: 86,
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not launch $url'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _deleteWorkout(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final deleted = await ref.read(adminProvider.notifier).deleteWorkout(id);
      if (!mounted) return;
      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout deleted'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting workout'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
