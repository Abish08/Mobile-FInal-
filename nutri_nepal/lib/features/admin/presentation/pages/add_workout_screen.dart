import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nutri_nepal/app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutri_nepal/features/admin/domain/entities/admin_entity.dart';
import 'package:nutri_nepal/features/admin/presentation/providers/admin_provider.dart';

class AddWorkoutScreen extends ConsumerStatefulWidget {
  final AdminWorkout? workoutData;

  const AddWorkoutScreen({super.key, this.workoutData});

  @override
  ConsumerState<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends ConsumerState<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _dayCtrl = TextEditingController();
  final _setsCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _restCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _intensityCtrl = TextEditingController();
  final _cyclesCtrl = TextEditingController();
  final _focusCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _youtubeUrlCtrl = TextEditingController();

  final List<File> _additionalImages = [];
  File? _thumbnailImage;
  String _category = 'Strength';
  String _day = 'Monday';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final workout = widget.workoutData;
    if (workout != null) {
      _nameCtrl.text = workout.name;
      _categoryCtrl.text = workout.category;
      _dayCtrl.text = workout.day;
      _setsCtrl.text = workout.sets?.toString() ?? '';
      _repsCtrl.text = workout.reps?.toString() ?? '';
      _restCtrl.text = workout.rest ?? '';
      _durationCtrl.text = workout.duration ?? '';
      _intensityCtrl.text = workout.intensity ?? '';
      _cyclesCtrl.text = workout.cycles?.toString() ?? '';
      _focusCtrl.text = workout.focus ?? '';
      _descriptionCtrl.text = workout.description ?? '';
      _youtubeUrlCtrl.text = workout.youtubeUrl ?? '';
      _category = workout.category;
      _day = workout.day;
    }
  }

  Future<void> _pickThumbnail() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _thumbnailImage = File(image.path));
    }
  }

  Future<void> _pickAdditionalImages() async {
    final images = await ImagePicker().pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (images.isNotEmpty) {
      setState(() => _additionalImages.addAll(images.map((e) => File(e.path))));
    }
  }

  void _removeAdditionalImage(int index) {
    setState(() => _additionalImages.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final saved = await ref
        .read(adminProvider.notifier)
        .saveWorkout(
          AdminWorkoutInput(
            id: widget.workoutData?.id,
            name: _nameCtrl.text.trim(),
            category: _category,
            day: _day,
            sets: int.tryParse(_setsCtrl.text),
            reps: int.tryParse(_repsCtrl.text),
            rest: _restCtrl.text.trim(),
            duration: int.tryParse(_durationCtrl.text),
            intensity: _intensityCtrl.text.trim(),
            cycles: int.tryParse(_cyclesCtrl.text),
            focus: _focusCtrl.text.trim(),
            description: _descriptionCtrl.text.trim(),
            youtubeUrl: _youtubeUrlCtrl.text.trim(),
            thumbnailImage: _thumbnailImage,
            additionalImages: _additionalImages,
          ),
        );

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (saved) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving workout'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.workoutData != null;
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Workout' : 'Add Workout',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Workout Name'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              items: [
                'Strength',
                'Cardio',
                'Flexibility',
                'Other',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() {
                _category = value!;
                _categoryCtrl.text = value;
              }),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _day,
              items: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() {
                _day = value!;
                _dayCtrl.text = value;
              }),
              decoration: const InputDecoration(labelText: 'Day'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setsCtrl,
                    decoration: const InputDecoration(labelText: 'Sets'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _repsCtrl,
                    decoration: const InputDecoration(labelText: 'Reps'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _restCtrl,
              decoration: const InputDecoration(labelText: 'Rest (e.g., 90s)'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _durationCtrl,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _intensityCtrl,
              decoration: const InputDecoration(
                labelText: 'Intensity (e.g., High)',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cyclesCtrl,
                    decoration: const InputDecoration(labelText: 'Cycles'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _focusCtrl,
                    decoration: const InputDecoration(labelText: 'Focus'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _youtubeUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'YouTube Video URL',
                hintText: 'https://www.youtube.com/watch?v=...',
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Thumbnail Image'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickThumbnail,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: _thumbnailImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_thumbnailImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add thumbnail',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Additional Images'),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _additionalImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _additionalImages.length) {
                    return GestureDetector(
                      onTap: _pickAdditionalImages,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.add, color: Colors.grey),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _additionalImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeAdditionalImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB85C00),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Workout' : 'Add Workout',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
        color: AppColors.white,
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _dayCtrl.dispose();
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    _restCtrl.dispose();
    _durationCtrl.dispose();
    _intensityCtrl.dispose();
    _cyclesCtrl.dispose();
    _focusCtrl.dispose();
    _descriptionCtrl.dispose();
    _youtubeUrlCtrl.dispose();
    super.dispose();
  }
}
