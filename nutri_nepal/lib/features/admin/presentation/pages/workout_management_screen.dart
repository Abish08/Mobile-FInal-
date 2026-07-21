import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/admin/presentation/widgets/workout_card.dart';
import 'package:nutri_nepal/features/auth/presentation/view_model/auth_viewmodel.dart';

class WorkoutManagementScreen extends ConsumerStatefulWidget {
  const WorkoutManagementScreen({super.key});

  @override
  ConsumerState<WorkoutManagementScreen> createState() => _WorkoutManagementScreenState();
}

class _WorkoutManagementScreenState extends ConsumerState<WorkoutManagementScreen> {
  List<Map<String, dynamic>> _workouts = [];
  bool _isLoading = true;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    
    final apiClient = ApiClient();
    try {
      final response = await apiClient.dio.get(ApiEndpoints.workouts);
      
      if (response.statusCode == 200) {
        final workoutsData = response.data['data'] as List;
        setState(() {
          _workouts = workoutsData;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load workouts: ${response.statusCode}'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading workouts: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addWorkout() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image'), backgroundColor: Colors.red),
      );
      return;
    }

    final apiClient = ApiClient();
    try {
      // First upload the image
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(_selectedImage!.path),
      });
      
      final uploadResponse = await apiClient.dio.post(
        ApiEndpoints.uploadWorkout,
        data: formData,
      );
      
      if (uploadResponse.statusCode != 200 || uploadResponse.data['url'] == null) {
        throw Exception('Image upload failed');
      }
      
      // Then create the workout with the image URL
      final workoutData = {
        'name': 'New Workout',
        'category': 'Strength',
        'duration': 30,
        'caloriesBurned': 300,
        'difficulty': 'Beginner',
        'description': 'A new workout added by admin',
        'images': [uploadResponse.data['url']],
        'media': [uploadResponse.data['url']],
        'isApproved': true,
      };
      
      final createResponse = await apiClient.dio.post(
        ApiEndpoints.workoutCreate,
        data: workoutData,
      );
      
      if (createResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout added successfully!'), backgroundColor: Colors.green),
        );
        await _loadWorkouts(); // Refresh the list
      } else {
        throw Exception('Workout creation failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding workout: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Workout Management', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addWorkout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Manage all workouts in your app',
              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'OpenSans'),
            ),
            const SizedBox(height: 24),
            _buildImageUploadSection(),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _workouts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => WorkoutCard(
                    workout: _workouts[index],
                    onDelete: () => _deleteWorkout(_workouts[index]['_id']),
                    onEdit: () => _editWorkout(_workouts[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add New Workout',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload an image for the new workout',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        _buildImagePicker(),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _selectedImage != null
            ? Image.file(_selectedImage!, fit: BoxFit.cover)
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Tap to upload image',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _deleteWorkout(String workoutId) async {
    final apiClient = ApiClient();
    try {
      final response = await apiClient.dio.delete(ApiEndpoints.workoutDelete(workoutId));
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout deleted successfully!'), backgroundColor: Colors.green),
        );
        await _loadWorkouts(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete workout: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting workout: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _editWorkout(Map<String, dynamic> workout) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit workout: ${workout['name']}'), backgroundColor: Colors.blue),
    );
    // TODO: Implement actual edit functionality
  }
}