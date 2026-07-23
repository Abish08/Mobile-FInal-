import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const MealCard({
    super.key,
    required this.meal,
    required this.onDelete,
    required this.onEdit,
  });

  // Helper to get image URL safely
  String _getImageUrl() {
    // Check thumbnail first, then images array
    final thumbnail = meal['thumbnail'];
    if (thumbnail != null && thumbnail['url'] != null) {
      return thumbnail['url'].toString();
    }
    
    final images = meal['images'];
    if (images != null && images is List && images.isNotEmpty) {
      return images[0]['url'].toString();
    }
    
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();
    // Note: If your backend returns relative paths like "/uploads/...", 
    // you might need to prepend your server IP here later.
    // For now, we use a placeholder if it fails.
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Meal Image
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
                          child: const Icon(Icons.restaurant, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16),
            
            // Meal Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal['name'] ?? 'Untitled Meal',
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
                    '${meal['category'] ?? 'General'} • ${meal['calories'] ?? 0} kcal',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'P: ${meal['protein'] ?? 0}g • C: ${meal['carbs'] ?? 0}g • F: ${meal['fats'] ?? 0}g',
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