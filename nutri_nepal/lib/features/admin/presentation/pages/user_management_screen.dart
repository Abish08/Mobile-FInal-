import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';
import 'package:nutri_nepal/features/admin/presentation/pages/user_detail_screen.dart';
import 'package:nutri_nepal/features/admin/presentation/providers/admin_provider.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  List<AuthEntity> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All Users';
  int _totalUsers = 0;
  int _newToday = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUsers();
      }
    });
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    final userList = await ref
        .read(adminProvider.notifier)
        .loadUsers(search: _searchQuery, goal: _goalFilter);
    if (!mounted) return;
    if (userList == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading users'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    setState(() {
      _users = userList.users;
      _totalUsers = userList.totalUsers;
      _newToday = userList.newToday;
      _isLoading = false;
    });
  }

  String get _goalFilter => _selectedFilter == 'Weight Loss'
      ? 'lose_weight'
      : _selectedFilter == 'Muscle Gain'
      ? 'gain_muscle'
      : _selectedFilter == 'Maintain'
      ? 'maintain'
      : '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'User Management',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadUsers();
              },
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All Users', 'Weight Loss', 'Muscle Gain', 'Maintain']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setState(() => _selectedFilter = filter);
                          _loadUsers();
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '$_totalUsers',
                    'Total Users',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '$_newToday',
                    'New Today',
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildUserCard(_users[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontFamily: 'OpenSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AuthEntity user) {
    double? bmi;
    if (user.height != null &&
        user.weight != null &&
        user.height! > 0 &&
        user.weight! > 0) {
      final heightInMeters = user.height! / 100;
      bmi = user.weight! / (heightInMeters * heightInMeters);
    }

    String bmiCategory = 'N/A';
    Color bmiColor = Colors.grey;

    if (bmi != null) {
      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
        bmiColor = Colors.blue;
      } else if (bmi < 25) {
        bmiCategory = 'Normal';
        bmiColor = Colors.green;
      } else if (bmi < 30) {
        bmiCategory = 'Overweight';
        bmiColor = Colors.orange;
      } else {
        bmiCategory = 'Obese';
        bmiColor = Colors.red;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF1B4332).withOpacity(0.1),
            child: Text(
              '${user.firstName[0]}${user.lastName[0]}',
              style: const TextStyle(
                color: Color(0xFF1B4332),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Goal: ${user.fitnessGoal ?? 'Not set'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: bmiColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BMI: ${bmi?.toStringAsFixed(1) ?? 'N/A'} ($bmiCategory)',
                    style: TextStyle(
                      fontSize: 12,
                      color: bmiColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.green),
                onPressed: () => _viewUser(user),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteUser(user.userId!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _viewUser(AuthEntity user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailScreen(user: user)),
    );
  }

  Future<void> _deleteUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final deleted = await ref.read(adminProvider.notifier).deleteUser(userId);
      if (!mounted) return;
      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
