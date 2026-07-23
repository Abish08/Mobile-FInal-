import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onDelete,
    required this.onEdit,
  });

  // Helper to get image URL safely
  String _getImageUrl() {
    final media = workout['media'];
    if (media != null && media is List && media.isNotEmpty) {
      // Check if it's an object with url or just a string
      if (media[0] is Map && media[0]['url'] != null) {
        return media[0]['url'].toString();
      }
      return media[0].toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Workout Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.fitness_center, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.fitness_center, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16),
            
            // Workout Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout['name'] ?? 'Untitled Workout',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workout['category'] ?? 'General'} • ${workout['difficulty'] ?? 'Medium'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workout['duration'] ?? 0} mins • ${workout['caloriesBurned'] ?? 0} kcal',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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