import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/admin/presentation/pages/add_workout_screen.dart';

class Workout {
  final String id;
  final String name;
  final String category;
  final String day;
  final String? difficulty;
  final String? duration;
  final int? caloriesBurned;
  final String? equipment;
  final String? thumbnail;
  final String? youtubeUrl;
  final Map<String, dynamic> rawData;

  Workout({
    required this.id,
    required this.name,
    required this.category,
    required this.day,
    this.difficulty,
    this.duration,
    this.caloriesBurned,
    this.equipment,
    this.thumbnail,
    this.youtubeUrl,
    required this.rawData,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic idField) {
      if (idField == null) return '';
      if (idField is String) return idField;
      if (idField is Map && idField.containsKey('\$oid')) return idField['\$oid'] as String;
      return idField.toString();
    }

    // Get thumbnail or first image from images array
    String? thumbnail;
    if (json['thumbnail'] != null) {
      thumbnail = json['thumbnail'];
    } else if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      thumbnail = (json['images'] as List)[0];
    }

    return Workout(
      id: extractId(json['_id']),
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? 'Other',
      day: json['day'] ?? 'Any Day',
      difficulty: json['difficulty'],
      duration: json['duration']?.toString(),
      caloriesBurned: json['caloriesBurned'] as int?,
      equipment: json['equipment'],
      thumbnail: thumbnail,
      youtubeUrl: json['youtubeUrl'],
      rawData: json,
    );
  }
}

class WorkoutManagementScreen extends ConsumerStatefulWidget {
  const WorkoutManagementScreen({super.key});

  @override
  ConsumerState<WorkoutManagementScreen> createState() => _WorkoutManagementScreenState();
}

class _WorkoutManagementScreenState extends ConsumerState<WorkoutManagementScreen> {
  List<Workout> _workouts = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get(
        ApiEndpoints.adminWorkouts,
        queryParameters: {
          'category': _selectedFilter != 'All' ? _selectedFilter : '',
        },
      );
      if (res.statusCode == 200) {
        setState(() {
          _workouts = (res.data['workouts'] as List).map((e) => Workout.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading workouts: $e');
      setState(() => _isLoading = false);
    }
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
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFFB85C00), size: 30),
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
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: ['All', 'Strength', 'Cardio', 'Flexibility']
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f),
                          selected: _selectedFilter == f,
                          onSelected: (s) {
                            setState(() => _selectedFilter = f);
                            _loadData();
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _workouts.isEmpty
                    ? const Center(child: Text('No workouts found', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _workouts.length,
                        itemBuilder: (context, index) => _buildCard(_workouts[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Workout w) {
    final serverUrl = ApiEndpoints.serverUrl;
    final imageUrl = w.thumbnail != null ? '$serverUrl${w.thumbnail}' : null;
    final youtubeUrl = w.youtubeUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Show Image if available
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.fitness_center, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.grey),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildChip(w.category, Colors.green),
                        _buildChip(w.day.toUpperCase(), Colors.orange),
                        if (w.difficulty != null) _buildChip(w.difficulty!, Colors.blue),
                      ],
                    ),
                    // ✅ Show YouTube Link if available
                    if (youtubeUrl != null && youtubeUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () => _launchUrl(youtubeUrl),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.play_circle_outline, color: Colors.red, size: 18),
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
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
                onPressed: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddWorkoutScreen(workoutData: w.rawData)),
                  );
                  if (res == true) _loadData();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                onPressed: () => _deleteWorkout(w.id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (w.duration != null) _buildMetric('Duration', '${w.duration}m'),
              if (w.caloriesBurned != null) _buildMetric('Calories', '${w.caloriesBurned}'),
              if (w.equipment != null && w.equipment!.isNotEmpty) _buildMetric('Equipment', w.equipment!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteWorkout(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiClient().dio.delete('/workouts/admin/$id');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout deleted'), backgroundColor: Colors.green),
        );
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}