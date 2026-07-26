import 'package:flutter/material.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';

class UserDetailScreen extends StatelessWidget {
  final AuthEntity user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    double? bmi;
    if (user.height != null && user.weight != null) {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'User Details',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF1B4332).withOpacity(0.1),
                    child: Text(
                      '${user.firstName[0]}${user.lastName[0]}',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Color(0xFF1B4332),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('Fitness Goal', user.fitnessGoal ?? 'Not set'),
                  const Divider(),
                  _buildInfoRow('Gender', user.gender?.toUpperCase() ?? 'Not set'),
                  const Divider(),
                  _buildInfoRow('Age', user.age != null ? '${user.age} years' : 'Not set'),
                  const Divider(),
                  _buildInfoRow('Weight', user.weight != null ? '${user.weight} kg' : 'Not set'),
                  const Divider(),
                  _buildInfoRow('Height', user.height != null ? '${user.height} cm' : 'Not set'),
                  const Divider(),
                  _buildInfoRow('BMI', bmi != null ? '${bmi.toStringAsFixed(1)} ($bmiCategory)' : 'N/A', valueColor: bmiColor),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('User ID', user.userId ?? 'Unknown'),
                  const Divider(),
                  _buildInfoRow('Role', (user as dynamic).role ?? 'user'),
                  const Divider(),
                  _buildInfoRow('Health Conditions', 
                    user.healthConditions?.isNotEmpty == true 
                      ? user.healthConditions!.join(', ')
                      : 'None'),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF1F2937),
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}