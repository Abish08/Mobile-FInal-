import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/providers/refresh_provider.dart';
import 'package:nutri_nepal/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:nutri_nepal/features/health_profile/domain/entities/health_profile_entity.dart';
import 'package:nutri_nepal/features/health_profile/presentation/providers/health_profile_provider.dart';

class HealthOnboardingScreen extends ConsumerStatefulWidget {
  const HealthOnboardingScreen({super.key});

  @override
  ConsumerState<HealthOnboardingScreen> createState() =>
      _HealthOnboardingScreenState();
}

class _HealthOnboardingScreenState
    extends ConsumerState<HealthOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String? _selectedGender;
  String? _selectedGoal;
  final List<String> _selectedConditions = [];
  bool _isLoading = false;
  double? _calculatedBMI;

  final List<String> _genders = ['male', 'female', 'other'];
  final List<String> _goals = [
    'lose_weight',
    'maintain',
    'gain_muscle',
    'bulk',
  ];
  final List<String> _conditions = [
    'None',
    'Diabetes',
    'Hypertension',
    'Lactose Sensitive',
    'Asthma',
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final heightCm = double.tryParse(_heightController.text);

    if (weight != null && weight > 0 && heightCm != null && heightCm > 0) {
      final heightM = heightCm / 100;
      setState(() {
        _calculatedBMI = weight / (heightM * heightM);
      });
    } else {
      setState(() {
        _calculatedBMI = null;
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 24.9) return 'Normal';
    if (bmi < 29.9) return 'Overweight';
    return 'Obese';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null || _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select gender and fitness goal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final savedProfile = await ref
          .read(healthProfileProvider.notifier)
          .saveProfile(
            HealthProfileEntity(
              age: int.parse(_ageController.text),
              weight: double.parse(_weightController.text),
              height: double.parse(_heightController.text),
              gender: _selectedGender!,
              fitnessGoal: _selectedGoal!,
              healthConditions: _selectedConditions.contains('None')
                  ? const []
                  : _selectedConditions,
              activityLevel: 'moderate',
              goal: _mapFitnessGoal(_selectedGoal!),
            ),
          );

      // ✅ Calls the PATCH endpoint we built in the backend
      if (savedProfile != null) {
        await ref.read(healthProfileProvider.notifier).loadProfile();
        await ref.read(authViewModelProvider.notifier).getCurrentUser();
        ref.read(refreshProvider.notifier).refresh();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapFitnessGoal(String fitnessGoal) {
    switch (fitnessGoal) {
      case 'lose_weight':
        return 'lose';
      case 'gain_muscle':
      case 'bulk':
        return 'gain';
      case 'maintain':
      default:
        return 'maintain';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Health Profile',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us about yourself',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This helps us calculate your BMI and personalize your plan.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontFamily: 'OpenSans',
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _ageController,
                      'Age',
                      '25',
                      TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      _weightController,
                      'Weight (kg)',
                      '70',
                      TextInputType.number,
                      onChanged: (_) => _calculateBMI(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      _heightController,
                      'Height (cm)',
                      '175',
                      TextInputType.number,
                      onChanged: (_) => _calculateBMI(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_calculatedBMI != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4332),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your BMI',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _calculatedBMI!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        _getBMICategory(_calculatedBMI!),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                _selectedGender,
                _genders,
                (val) => setState(() => _selectedGender = val),
              ),
              const SizedBox(height: 20),
              const Text(
                'Fitness Goal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                _selectedGoal,
                _goals,
                (val) => setState(() => _selectedGoal = val),
              ),
              const SizedBox(height: 24),
              const Text(
                'Health Conditions (Select all that apply)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _conditions.map((condition) {
                  final isSelected = _selectedConditions.contains(condition);
                  return FilterChip(
                    label: Text(
                      condition,
                      style: const TextStyle(fontFamily: 'Montserrat'),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (condition == 'None') _selectedConditions.clear();
                          _selectedConditions.add(condition);
                        } else {
                          _selectedConditions.remove(condition);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF1B4332),
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB85C00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    TextInputType type, {
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontFamily: 'OpenSans',
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: type,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Required';
            final number = double.tryParse(val);
            if (number == null || number <= 0) return 'Invalid';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: const Text(
            'Select',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontFamily: 'Montserrat'),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
