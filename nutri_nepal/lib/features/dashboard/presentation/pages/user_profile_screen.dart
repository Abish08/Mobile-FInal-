import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/services/image_upload_service.dart';
import 'package:nutri_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:nutri_nepal/features/auth/presentation/view_model/auth_viewmodel.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final ImageUploadService _imageUploadService = ImageUploadService();
  File? _profileImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // ✅ Fetch fresh user data when profile screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).getCurrentUser();
    });
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    setState(() => _isUploading = true);

    File? imageFile;
    if (source == ImageSource.gallery) {
      imageFile = await _imageUploadService.pickImageFromGallery();
    } else {
      imageFile = await _imageUploadService.pickImageFromCamera();
    }

    if (imageFile != null) {
      setState(() {
        _profileImage = imageFile;
      });

      final uploadedUrl = await _imageUploadService.uploadProfilePicture(imageFile);

      if (uploadedUrl != null) {
        await _updateUserProfileWithImageUrl(uploadedUrl);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image'), backgroundColor: Colors.red),
          );
        }
      }
    }

    if (mounted) {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _updateUserProfileWithImageUrl(String imageUrl) async {
    try {
      final apiClient = ApiClient();
      
      final response = await apiClient.dio.patch(
        '/users/profile',
        data: {
          'profilePicture': imageUrl,
        },
      );

      if (response.statusCode == 200 && mounted) {
        // ✅ Refresh user data after updating profile picture
        await ref.read(authViewModelProvider.notifier).getCurrentUser();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile picture: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF1B4332)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1B4332)),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'User Profile',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1B4332)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Image with Upload
            GestureDetector(
              onTap: _isUploading ? null : _showImageSourceDialog,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4332).withOpacity(0.1),
                      shape: BoxShape.circle,
                      // ✅ Load saved image from user.profilePicture
                      image: _profileImage != null
                          ? DecorationImage(
                              image: FileImage(_profileImage!),
                              fit: BoxFit.cover,
                            )
                          : user.profilePicture != null && user.profilePicture!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(user.profilePicture!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: _profileImage == null && (user.profilePicture == null || user.profilePicture!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF1B4332),
                          )
                        : null,
                  ),
                  if (_isUploading)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1B4332),
                        ),
                      ),
                    )
                  else
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFB85C00),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // User Name
            Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Member since Jan 2024',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 16),
            
            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB85C00),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Vital Metrics
            _buildSectionCard(
              'VITAL METRICS',
              [
                _buildMetricRow(
                  'Age',
                  user.age != null ? '${user.age} yrs' : 'Not set',
                  'Weight',
                  user.weight != null ? '${user.weight!.toStringAsFixed(1)} kg' : 'Not set',
                ),
                const SizedBox(height: 16),
                _buildMetricRow(
                  'Height',
                  user.height != null ? '${user.height!.toStringAsFixed(0)} cm' : 'Not set',
                  'Goal',
                  _formatGoal(user.fitnessGoal),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Health Conditions
            _buildSectionCard(
              'HEALTH CONDITIONS',
              [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user.healthConditions != null && user.healthConditions!.isNotEmpty
                      ? user.healthConditions!.map((condition) => _buildHealthChip(
                            condition,
                            _getConditionColor(condition),
                          )).toList()
                      : [
                          _buildHealthChip('No Conditions', Colors.grey),
                        ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Account Settings
            _buildSectionCard(
              'ACCOUNT SETTINGS',
              [
                _buildSettingItem(Icons.lock_outline, 'Privacy & Security'),
                const Divider(height: 1),
                _buildSettingItem(Icons.language, 'Language',
                    trailing: Text('English (US)',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 14))),
                const Divider(height: 1),
                GestureDetector(
                  onTap: () async {
                    final authNotifier = ref.read(authViewModelProvider.notifier);
                    await authNotifier.logout();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: _buildSettingItem(Icons.logout, 'Sign Out',
                      trailing: const Icon(Icons.chevron_right, color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _formatGoal(String? goal) {
    if (goal == null) return 'Not set';
    switch (goal) {
      case 'lose_weight':
        return 'Lose Weight';
      case 'maintain':
        return 'Maintain';
      case 'gain_muscle':
        return 'Muscle Gain';
      case 'bulk':
        return 'Bulk';
      default:
        return 'Not set';
    }
  }

  Color _getConditionColor(String condition) {
    if (condition.toLowerCase().contains('allerg')) return Colors.green;
    if (condition.toLowerCase().contains('sodium')) return Colors.teal;
    if (condition.toLowerCase().contains('lactose')) return Colors.orange;
    return Colors.blue;
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontFamily: 'OpenSans',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontFamily: 'OpenSans',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF6B7280), size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1F2937),
          fontFamily: 'Montserrat',
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
    );
  }
}