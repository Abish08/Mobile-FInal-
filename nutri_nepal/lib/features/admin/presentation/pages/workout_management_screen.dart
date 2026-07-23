import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/admin/presentation/pages/add_workout_screen.dart';

class Workout {
  final String id;
  final String name;
  final String category;
  final int? duration;
  final int? caloriesBurned;
  final String? difficulty;
  final String? description;
  final String? equipment;
  final Map<String, dynamic> rawData;

  Workout({
    required this.id,
    required this.name,
    required this.category,
    this.duration,
    this.caloriesBurned,
    this.difficulty,
    this.description,
    this.equipment,
    required this.rawData,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic idField) {
      if (idField == null) return '';
      if (idField is String) return idField;
      if (idField is Map && idField.containsKey('\$oid')) return idField['\$oid'] as String;
      return idField.toString();
    }

    return Workout(
      id: extractId(json['_id']),
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? 'Other',
      duration: json['duration'] as int?,
      caloriesBurned: json['caloriesBurned'] as int?,
      difficulty: json['difficulty'] as String?,
      description: json['description'] as String?,
      equipment: json['equipment'] as String?,
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
                    ? const Center(child: Text('No workouts found'))
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      w.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            w.category,
                            style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (w.difficulty != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              w.difficulty!,
                              style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddWorkoutScreen(workoutData: w.rawData)),
                  );
                  if (res == true) _loadData();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Workout'),
                      content: const Text('Are you sure?'),
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
                    await ApiClient().dio.delete(ApiEndpoints.adminWorkoutDelete(w.id));
                    _loadData();
                  }
                },
              ),
            ],
          ),
          const Divider(height: 20),
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

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
      ],
    );
  }
}