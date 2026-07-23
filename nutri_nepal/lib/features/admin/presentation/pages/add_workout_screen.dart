import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';

class AddWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic>? workoutData;
  
  const AddWorkoutScreen({super.key, this.workoutData});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
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

  File? _thumbnailImage;
  final List<File> _additionalImages = [];

  String _category = 'Strength';
  String _day = 'Monday';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.workoutData != null) {
      _loadWorkoutData();
    }
  }

  void _loadWorkoutData() {
    final d = widget.workoutData!;
    
    // ✅ Safe conversion: convert everything to String
    _nameCtrl.text = (d['name'] ?? '').toString();
    _categoryCtrl.text = (d['category'] ?? 'Strength').toString();
    _dayCtrl.text = (d['day'] ?? 'Monday').toString();
    _setsCtrl.text = (d['sets'] ?? '').toString();
    _repsCtrl.text = (d['reps'] ?? '').toString();
    _restCtrl.text = (d['rest'] ?? '').toString();
    _durationCtrl.text = (d['duration'] ?? '').toString(); // ✅ Fixed: convert int to String
    _intensityCtrl.text = (d['intensity'] ?? '').toString();
    _cyclesCtrl.text = (d['cycles'] ?? '').toString();
    _focusCtrl.text = (d['focus'] ?? '').toString();
    _descriptionCtrl.text = (d['description'] ?? '').toString();
    _youtubeUrlCtrl.text = (d['youtubeUrl'] ?? '').toString();
    
    // Set dropdown values
    _category = _categoryCtrl.text;
    _day = _dayCtrl.text;
  }

  Future<void> _pickThumbnail() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _thumbnailImage = File(image.path);
      });
    }
  }

  Future<void> _pickAdditionalImages() async {
    final List<XFile> images = await ImagePicker().pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _additionalImages.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  void _removeAdditionalImage(int index) {
    setState(() {
      _additionalImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text,
      'category': _categoryCtrl.text,
      'day': _dayCtrl.text,
      'sets': int.tryParse(_setsCtrl.text),
      'reps': int.tryParse(_repsCtrl.text),
      'rest': _restCtrl.text,
      'duration': _durationCtrl.text.isEmpty ? null : int.tryParse(_durationCtrl.text),
      'intensity': _intensityCtrl.text,
      'cycles': int.tryParse(_cyclesCtrl.text),
      'focus': _focusCtrl.text,
      'description': _descriptionCtrl.text,
      'youtubeUrl': _youtubeUrlCtrl.text,
    };

    try {
      if (widget.workoutData != null) {
        final id = widget.workoutData!['_id'] is Map ? widget.workoutData!['_id']['\$oid'] : widget.workoutData!['_id'];
        await ApiClient().dio.put('/workouts/admin/$id', data: data);
      } else {
        await ApiClient().dio.post('/workouts/admin', data: data);
      }

      // Upload thumbnail if selected
      if (_thumbnailImage != null && widget.workoutData != null) {
        final id = widget.workoutData!['_id'] is Map ? widget.workoutData!['_id']['\$oid'] : widget.workoutData!['_id'];
        await _uploadThumbnail(id);
      }

      // Upload additional images if any
      if (_additionalImages.isNotEmpty && widget.workoutData != null) {
        final id = widget.workoutData!['_id'] is Map ? widget.workoutData!['_id']['\$oid'] : widget.workoutData!['_id'];
        await _uploadAdditionalImages(id);
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadThumbnail(String id) async {
    final apiClient = ApiClient();
    final file = _thumbnailImage!;
    
    final formData = FormData.fromMap({
      'thumbnail': await MultipartFile.fromFile(
        file.path,
        filename: path.basename(file.path),
      ),
    });

    await apiClient.dio.post(
      '/workouts/$id/upload-thumbnail',
      data: formData,
    );
  }

  Future<void> _uploadAdditionalImages(String id) async {
    final apiClient = ApiClient();
    final List<MultipartFile> files = [];
    
    for (var image in _additionalImages) {
      files.add(await MultipartFile.fromFile(
        image.path,
        filename: path.basename(image.path),
      ));
    }

    final formData = FormData.fromMap({
      'images': files,
    });

    await apiClient.dio.post(
      '/workouts/$id/upload-images',
      data: formData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.workoutData != null ? 'Edit Workout' : 'Add Workout',
          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: 'Workout Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _category,
              items: ['Strength', 'Cardio', 'Flexibility', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _day,
              items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _day = v!),
              decoration: InputDecoration(labelText: 'Day'),
            ),
            const SizedBox(height: 16),

            // Metrics
            Row(
              children: [
                Expanded(child: TextFormField(
                  controller: _setsCtrl,
                  decoration: InputDecoration(labelText: 'Sets'),
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(
                  controller: _repsCtrl,
                  decoration: InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                )),
              ],
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _restCtrl,
              decoration: InputDecoration(labelText: 'Rest (e.g., 90s)'),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _durationCtrl,
              decoration: InputDecoration(labelText: 'Duration (minutes)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _intensityCtrl,
              decoration: InputDecoration(labelText: 'Intensity (e.g., High)'),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(child: TextFormField(
                  controller: _cyclesCtrl,
                  decoration: InputDecoration(labelText: 'Cycles'),
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(
                  controller: _focusCtrl,
                  decoration: InputDecoration(labelText: 'Focus'),
                )),
              ],
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _descriptionCtrl,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // YouTube URL
            TextFormField(
              controller: _youtubeUrlCtrl,
              decoration: InputDecoration(
                labelText: 'YouTube Video URL',
                hintText: 'https://www.youtube.com/watch?v=...',
              ),
            ),
            const SizedBox(height: 24),

            // Thumbnail Section
            _buildSectionTitle('Thumbnail Image'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickThumbnail,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _thumbnailImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_thumbnailImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey.shade400),
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

            // Additional Images
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_additionalImages[index], fit: BoxFit.cover),
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
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB85C00),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : Text(
                        widget.workoutData != null ? 'Update Workout' : 'Add Workout',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
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
        color: Color(0xFF1F2937),
      ),
    );
  }
}