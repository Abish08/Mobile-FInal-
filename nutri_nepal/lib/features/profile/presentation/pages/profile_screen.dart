import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nutri_nepal/app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutri_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:nutri_nepal/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:nutri_nepal/features/health_profile/presentation/pages/health_onboarding_screen.dart';
import 'package:nutri_nepal/features/profile/presentation/providers/profile_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    setState(() => _isUploading = true);

    try {
      final image = await _imagePicker.pickImage(source: source);
      final imageFile = image == null ? null : File(image.path);

      if (imageFile != null) {
        setState(() {
          _profileImage = imageFile;
        });

        final updatedProfile = await ref
            .read(profileProvider.notifier)
            .uploadProfileImage(imageFile);

        if (!mounted) return;

        if (updatedProfile != null) {
          setState(() => _profileImage = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: AppColors.primaryOrange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primaryOrange,
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primaryOrange,
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
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
    final profileState = ref.watch(profileProvider);

    if (profileState.isLoading && profileState.asData?.value == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profileState.hasError && profileState.asData?.value == null) {
      return Scaffold(
        backgroundColor: AppColors.appBackground,
        appBar: AppBar(
          backgroundColor: AppColors.appBackground,
          elevation: 0,
          title: const Text(
            'Profile',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profileState.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontFamily: 'OpenSans',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(profileProvider.notifier).retry(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = profileState.asData?.value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _isUploading ? null : _showImageSourceDialog,
                  child: Stack(
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          image: _profileImage != null
                              ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover,
                                )
                              : user.profilePictureUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(user.profilePictureUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            _profileImage == null &&
                                user.profilePictureUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 42,
                                color: AppColors.primaryOrange,
                              )
                            : null,
                      ),
                      if (_isUploading)
                        const Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        )
                      else
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: Color(0xFFB85C00),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatGoal(user.fitnessGoal),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const HealthOnboardingScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit profile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryOrange,
                          side: const BorderSide(
                            color: AppColors.primaryOrange,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildMetricTile(
                  'Age',
                  user.age != null ? '${user.age}' : '--',
                ),
                _buildMetricTile(
                  'Weight',
                  user.weight != null
                      ? '${user.weight!.toStringAsFixed(1)} kg'
                      : '--',
                ),
                _buildMetricTile(
                  'Height',
                  user.height != null
                      ? '${user.height!.toStringAsFixed(0)} cm'
                      : '--',
                ),
                _buildMetricTile('Goal', _formatGoal(user.fitnessGoal)),
              ],
            ),
            const SizedBox(height: 28),

            const Text(
              'Health Conditions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.healthConditions.isNotEmpty
                  ? user.healthConditions
                        .map(
                          (condition) => _buildHealthChip(
                            condition,
                            _getConditionColor(condition),
                          ),
                        )
                        .toList()
                  : [_buildHealthChip('No conditions', Colors.grey)],
            ),
            const SizedBox(height: 28),

            const Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
              ),
              child: Column(
                children: [
                  _buildSettingItem(Icons.lock_outline, 'Privacy & Security'),
                  const Divider(height: 1),
                  _buildSettingItem(
                    Icons.language_outlined,
                    'Language',
                    trailing: const Text(
                      'English',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 14,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  InkWell(
                    onTap: () async {
                      final authNotifier = ref.read(
                        authViewModelProvider.notifier,
                      );
                      await authNotifier.logout();
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: _buildSettingItem(
                      Icons.logout,
                      'Sign Out',
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.red,
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

  Widget _buildMetricTile(String label, String value) {
    return Container(
      width: (MediaQuery.of(context).size.width - 42) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontFamily: 'OpenSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.grey, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.white,
          fontFamily: 'Montserrat',
        ),
      ),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: AppColors.grey),
    );
  }
}
