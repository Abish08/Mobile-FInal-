import 'package:flutter/material.dart';
import 'package:nutri_nepal/features/auth/domain/entities/auth_entity.dart';

class UserCard extends StatelessWidget {
  final AuthEntity user;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const UserCard({
    super.key,
    required this.user,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF1B4332).withOpacity(0.1),
              child: Text(
                '${user.firstName[0]}${user.lastName[0]}',
                style: const TextStyle(color: Color(0xFF1B4332), fontSize: 20),
              ),
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontFamily: 'OpenSans',
                    ),
                  ),
                  Text(
                    'Age: ${user.age ?? 'N/A'} | Height: ${user.height ?? 'N/A'} cm | Weight: ${user.weight ?? 'N/A'} kg',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}