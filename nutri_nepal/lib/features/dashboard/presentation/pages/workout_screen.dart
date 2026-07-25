import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';

class UserWorkout {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? thumbnail;
  final String? youtubeUrl;
  final String? duration;
  final int? caloriesBurned;

  UserWorkout({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.thumbnail,
    this.youtubeUrl,
    this.duration,
    this.caloriesBurned,
  });

  factory UserWorkout.fromJson(Map<String, dynamic> json) {
    String? thumb;
    if (json['thumbnail'] != null) {
      thumb = json['thumbnail'];
    } else if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      thumb = (json['images'] as List)[0];
    }

    return UserWorkout(
      id: json['_id'] is Map ? json['_id']['\$oid'] : (json['_id']?.toString() ?? ''),
      name: json['name'] ?? 'Unknown Workout',
      category: json['category'] ?? 'General',
      description: json['description'],
      thumbnail: thumb,
      youtubeUrl: json['youtubeUrl'],
      duration: json['duration']?.toString(),
      caloriesBurned: json['caloriesBurned'] != null ? (json['caloriesBurned'] as num).toInt() : null,
    );
  }
}

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> with SingleTickerProviderStateMixin {
  List<UserWorkout> _workouts = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  late AnimationController _animationController;
  String? _userId;

  final List<String> _categories = ['All', 'Strength', 'Cardio', 'Flexibility', 'Other'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fetchUserId();
    _fetchWorkouts();
  }

  Future<void> _fetchUserId() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get(ApiEndpoints.getProfile);
      if (response.statusCode == 200) {
        final userData = response.data['data'] ?? response.data;
        setState(() {
          _userId = userData['_id'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching user ID: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().dio.get(ApiEndpoints.publicWorkouts);
      if (response.statusCode == 200) {
        List rawData = [];
        if (response.data is List) {
          rawData = response.data;
        } else if (response.data['workouts'] is List) {
          rawData = response.data['workouts'];
        } else if (response.data['data'] is List) {
          rawData = response.data['data'];
        }

        setState(() {
          _workouts = rawData.map((e) => UserWorkout.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<UserWorkout> get _filteredWorkouts {
    if (_selectedCategory == 'All') return _workouts;
    return _workouts.where((w) => w.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  Future<void> _launchYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength': return const Color(0xFFB85C00);
      case 'cardio': return const Color(0xFF1B4332);
      case 'flexibility': return Colors.purple;
      default: return Colors.blue;
    }
  }

  // ✅ FULLY FIXED LOGGING FUNCTION
  Future<void> _logWorkout(UserWorkout workout) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final apiClient = ApiClient();
      
      // ✅ THE ULTIMATE FIX: 
      // 1. 'name' satisfies Mongoose Schema
      // 2. 'exerciseName' satisfies DTO Validation
      // 3. 'duration' is sent as a String to prevent Mongoose Cast Errors
      final workoutData = {
        'name': workout.name,           
        'exerciseName': workout.name,   
        'category': workout.category,   
        'duration': workout.duration ?? '0', // ✅ Sent as String
        'caloriesBurned': workout.caloriesBurned ?? 0,
        'userId': _userId,
        'sets': 1, 
        'reps': 1, 
      };

      debugPrint('🔍 SENDING WORKOUT DATA: $workoutData');

      final response = await apiClient.dio.post(
        ApiEndpoints.workoutCreate,
        data: workoutData,
      );

      debugPrint('✅ RESPONSE: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${workout.name} logged successfully!'),
            backgroundColor: const Color(0xFF1B4332),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ DIO ERROR DETAILS: $e');
      debugPrint('❌ RESPONSE DATA: ${e.response?.data}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.response?.data['message'] ?? e.message}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('❌ GENERAL ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Workouts',
          style: TextStyle(color: Color(0xFF1F2937), fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF1B4332)), onPressed: _fetchWorkouts),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
          : Column(
              children: [
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1B4332) : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: isSelected ? const Color(0xFF1B4332) : Colors.grey.shade300, width: 1.5),
                            boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF1B4332).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF6B7280), fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontFamily: 'Montserrat'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _filteredWorkouts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fitness_center, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No workouts found', style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontFamily: 'Montserrat')),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchWorkouts,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredWorkouts.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) => _buildEnhancedWorkoutCard(_filteredWorkouts[index], index),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEnhancedWorkoutCard(UserWorkout workout, int index) {
    final categoryColor = _getCategoryColor(workout.category);
    
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(offset: Offset(0, 50 * (1 - value)), child: Opacity(opacity: value, child: child));
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  workout.thumbnail != null
                      ? Image.network(ApiEndpoints.resolveUploadUrl(workout.thumbnail!), height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildPlaceholder())
                      : _buildPlaceholder(),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.6)])),
                    ),
                  ),
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(20)),
                      child: Text(workout.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: categoryColor, fontFamily: 'Montserrat')),
                    ),
                  ),
                  if (workout.youtubeUrl != null && workout.youtubeUrl!.isNotEmpty)
                    Positioned(
                      top: 12, right: 12,
                      child: GestureDetector(
                        onTap: () => _launchYouTube(workout.youtubeUrl!),
                        child: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.play_arrow, color: Colors.white, size: 20)),
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
                  Text(workout.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), fontFamily: 'Montserrat')),
                  if (workout.description != null && workout.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(workout.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontFamily: 'OpenSans')),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (workout.duration != null && workout.duration!.isNotEmpty) _buildStatChip(Icons.access_time, '${workout.duration} min', Colors.orange),
                      if (workout.caloriesBurned != null) ...[
                        const SizedBox(width: 12),
                        _buildStatChip(Icons.local_fire_department, '${workout.caloriesBurned} kcal', Colors.red),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _logWorkout(workout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB85C00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_outline, size: 22),
                          SizedBox(width: 8),
                          Text('Start Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
                        ],
                      ),
                    ),
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
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE0E0E0), Color(0xFFF5F5F5)])),
      child: const Icon(Icons.fitness_center, size: 64, color: Color(0xFFBDBDBD)),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color, fontFamily: 'Montserrat'))],
      ),
    );
  }
}