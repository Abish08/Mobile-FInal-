import 'package:flutter/material.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';

class AddWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic>? workoutData;
  const AddWorkoutScreen({super.key, this.workoutData});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _equipmentCtrl = TextEditingController();

  String _category = 'Strength';
  String _difficulty = 'Beginner';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.workoutData != null) {
      final d = widget.workoutData!;
      _nameCtrl.text = d['name'] ?? '';
      _category = d['category'] ?? 'Strength';
      _difficulty = d['difficulty'] ?? 'Beginner';
      _durationCtrl.text = (d['duration'] ?? '').toString();
      _caloriesCtrl.text = (d['caloriesBurned'] ?? '').toString();
      _descriptionCtrl.text = d['description'] ?? '';
      _equipmentCtrl.text = d['equipment'] ?? '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text,
      'category': _category,
      'difficulty': _difficulty,
      'duration': int.tryParse(_durationCtrl.text),
      'caloriesBurned': int.tryParse(_caloriesCtrl.text),
      'description': _descriptionCtrl.text,
      'equipment': _equipmentCtrl.text,
      'isApproved': true,
    };

    try {
      if (widget.workoutData != null) {
        final id = widget.workoutData!['_id'] is Map
            ? widget.workoutData!['_id']['\$oid']
            : widget.workoutData!['_id'];
        await ApiClient().dio.put(ApiEndpoints.adminWorkoutUpdate(id), data: data);
      } else {
        await ApiClient().dio.post(ApiEndpoints.adminWorkoutCreate, data: data);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutData != null ? 'Edit Workout' : 'Add Workout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Workout Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              items: ['Strength', 'Cardio', 'Flexibility', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _difficulty,
              items: ['Beginner', 'Intermediate', 'Advanced']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _difficulty = v!),
              decoration: const InputDecoration(labelText: 'Difficulty'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationCtrl,
              decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caloriesCtrl,
              decoration: const InputDecoration(labelText: 'Calories Burned'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _equipmentCtrl,
              decoration: const InputDecoration(labelText: 'Equipment'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB85C00),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Workout', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}