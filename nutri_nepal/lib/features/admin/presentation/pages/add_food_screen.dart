import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:path/path.dart' as path; // ✅ FIXED: Added 'as path' prefix to avoid collision
import 'package:dio/dio.dart';

class AddFoodScreen extends StatefulWidget {
  final Map<String, dynamic>? foodData;
  
  const AddFoodScreen({super.key, this.foodData});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sugarController = TextEditingController();
  final _sodiumController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _thumbnailImage;
  final List<File> _additionalImages = [];
  bool _isLoading = false;
  bool _isApproved = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.foodData != null) {
      _loadFoodData();
    }
  }

  void _loadFoodData() {
    final data = widget.foodData!;
    _nameController.text = data['name'] ?? '';
    _categoryController.text = data['category'] ?? '';
    _servingSizeController.text = (data['servingSize'] ?? 100).toString();
    _caloriesController.text = (data['calories'] ?? 0).toString();
    _proteinController.text = (data['protein'] ?? 0).toString();
    _carbsController.text = (data['carbs'] ?? 0).toString();
    _fatsController.text = (data['fats'] ?? 0).toString();
    _fiberController.text = (data['fiber'] ?? 0).toString();
    _sugarController.text = (data['sugar'] ?? 0).toString();
    _sodiumController.text = (data['sodium'] ?? 0).toString();
    _descriptionController.text = data['description'] ?? '';
    _isApproved = data['isApproved'] ?? true;
  }

  Future<void> _pickThumbnail() async {
    final XFile? image = await _picker.pickImage(
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
    final List<XFile> images = await _picker.pickMultiImage(
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiClient = ApiClient();
      
      final formData = {
        'name': _nameController.text.trim(),
        'category': _categoryController.text.trim(),
        'servingSize': int.parse(_servingSizeController.text),
        'calories': int.parse(_caloriesController.text),
        'protein': double.parse(_proteinController.text),
        'carbs': double.parse(_carbsController.text),
        'fats': double.parse(_fatsController.text),
        'fiber': double.tryParse(_fiberController.text) ?? 0,
        'sugar': double.tryParse(_sugarController.text) ?? 0,
        'sodium': double.tryParse(_sodiumController.text) ?? 0,
        'description': _descriptionController.text.trim(),
        'isApproved': _isApproved,
      };

      String? foodId;

      if (widget.foodData != null) {
        foodId = widget.foodData!['_id'] is Map 
          ? widget.foodData!['_id']['\$oid'] 
          : widget.foodData!['_id'];
        
        await apiClient.dio.put(
          '/foods/$foodId',
          data: formData,
        );
      } else {
        final newFoodRes = await apiClient.dio.post(
          '/foods',
          data: formData,
        );
        foodId = newFoodRes.data['data']['_id'];
      }

      if (_thumbnailImage != null && foodId != null) {
        await _uploadThumbnail(foodId);
      }

      if (_additionalImages.isNotEmpty && foodId != null) {
        await _uploadAdditionalImages(foodId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( // ✅ Now 'context' correctly refers to BuildContext
          SnackBar(
            content: Text(widget.foodData == null 
              ? 'Food added successfully!' 
              : 'Food updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadThumbnail(String foodId) async {
    final apiClient = ApiClient();
    final file = _thumbnailImage!;
    
    final formData = FormData.fromMap({
      'thumbnail': await MultipartFile.fromFile(
        file.path,
        filename: path.basename(file.path), // ✅ FIXED: Used path.basename
      ),
    });

    await apiClient.dio.post(
      '/foods/$foodId/upload-thumbnail',
      data: formData,
    );
  }

  Future<void> _uploadAdditionalImages(String foodId) async {
    final apiClient = ApiClient();
    final List<MultipartFile> files = [];
    
    for (var image in _additionalImages) {
      files.add(await MultipartFile.fromFile(
        image.path,
        filename: path.basename(image.path), // ✅ FIXED: Used path.basename
      ));
    }

    final formData = FormData.fromMap({
      'images': files,
    });

    await apiClient.dio.post(
      '/foods/$foodId/upload-images',
      data: formData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.foodData != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Food' : 'Add New Food',
          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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

            _buildSectionTitle('Additional Images'),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _additionalImages.length + 1,
                itemBuilder: (context, index) { // ✅ This 'context' is safely scoped to the builder
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

            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Food Name', Icons.restaurant),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _categoryController,
              decoration: _inputDecoration('Category (e.g., Traditional, High Protein)', Icons.category),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _servingSizeController,
              decoration: _inputDecoration('Serving Size (grams)', Icons.scale),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Nutritional Information'),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(child: _buildNutrientField(_caloriesController, 'Calories', Icons.local_fire_department, Colors.red)),
                const SizedBox(width: 8),
                Expanded(child: _buildNutrientField(_proteinController, 'Protein (g)', Icons.fitness_center, Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildNutrientField(_carbsController, 'Carbs (g)', Icons.bakery_dining, Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildNutrientField(_fatsController, 'Fats (g)', Icons.water_drop, Colors.yellow.shade700)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildNutrientField(_fiberController, 'Fiber (g)', Icons.grass, Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _buildNutrientField(_sugarController, 'Sugar (g)', Icons.cake, Colors.pink)),
              ],
            ),
            const SizedBox(height: 8),
            _buildNutrientField(_sodiumController, 'Sodium (mg)', Icons.medical_services, Colors.purple),

            const SizedBox(height: 24),

            _buildSectionTitle('Description'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration('Description', Icons.description).copyWith(
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            SwitchListTile(
              title: const Text('Approved (visible to users)'),
              subtitle: const Text('Turn off to set as pending approval'),
              value: _isApproved,
              onChanged: (value) => setState(() => _isApproved = value),
              activeColor: Colors.green,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : Text(
                        isEditing ? 'Update Food' : 'Add Food',
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

  Widget _buildNutrientField(TextEditingController controller, String label, IconData icon, Color color) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}