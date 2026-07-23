import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';
import 'package:nutri_nepal/features/admin/presentation/pages/add_food_screen.dart';

class Meal {
  final String id;
  final String name;
  final String category;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final String servingSize;
  final String status;
  final String? thumbnail;
  final List<String>? images;
  final Map<String, dynamic> rawData;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.servingSize,
    required this.status,
    this.thumbnail,
    this.images,
    required this.rawData,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    String extractId(dynamic idField) {
      if (idField == null) return '';
      if (idField is String) return idField;
      if (idField is Map && idField.containsKey('\$oid')) {
        return idField['\$oid'] as String;
      }
      return idField.toString();
    }

    // Get thumbnail or first image
    String? thumbnail;
    if (json['thumbnail'] != null) {
      thumbnail = json['thumbnail'];
    } else if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      thumbnail = (json['images'] as List)[0];
    }

    return Meal(
      id: extractId(json['_id']),
      name: json['name'] ?? json['mealName'] ?? 'Unknown',
      category: json['category'] ?? 'General',
      calories: toInt(json['calories']),
      protein: toDouble(json['protein']),
      carbs: toDouble(json['carbs']),
      fats: toDouble(json['fats']),
      servingSize: '${json['servingSize'] ?? 100}g',
      status: json['isApproved'] == false ? 'pending' : 'approved',
      thumbnail: thumbnail,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      rawData: json,
    );
  }
}

class MealManagementScreen extends ConsumerStatefulWidget {
  const MealManagementScreen({super.key});

  @override
  ConsumerState<MealManagementScreen> createState() => _MealManagementScreenState();
}

class _MealManagementScreenState extends ConsumerState<MealManagementScreen> {
  List<Meal> _meals = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _totalItems = 0;
  int _pendingApproval = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final apiClient = ApiClient();
    
    try {
      final statsRes = await apiClient.dio.get(ApiEndpoints.adminMealStats);
      if (statsRes.statusCode == 200) {
        setState(() {
          _totalItems = statsRes.data['stats']['totalItems'] ?? 0;
          _pendingApproval = statsRes.data['stats']['pendingApproval'] ?? 0;
        });
      }

      final mealsRes = await apiClient.dio.get(
        ApiEndpoints.adminMeals,
        queryParameters: {
          'search': _searchQuery,
          'category': _selectedFilter != 'All' ? _selectedFilter.toLowerCase() : '',
        },
      );

      if (mealsRes.statusCode == 200) {
        final mealsData = mealsRes.data['foods'] as List;
        setState(() {
          _meals = mealsData.map((e) => Meal.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Food Management',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF1B4332), size: 30),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddFoodScreen()),
              );
              
              if (result == true) {
                _loadData();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search food items...',
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
                _loadData();
              },
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Traditional', 'High Protein', 'Pending']
                  .map((filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() => _selectedFilter = filter);
                            _loadData();
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('$_totalItems', 'Total Items', Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('$_pendingApproval', 'Pending', Colors.orange),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _meals.isEmpty
                    ? const Center(child: Text('No meals found', style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _meals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildMealCard(_meals[index]),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, fontFamily: 'Montserrat'),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontFamily: 'OpenSans')),
        ],
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    final serverUrl = ApiEndpoints.serverUrl;
    final imageUrl = meal.thumbnail != null ? '$serverUrl${meal.thumbnail}' : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: meal.status == 'pending' ? Border.all(color: Colors.orange, width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Show image if available
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.restaurant, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${meal.category} • ${meal.servingSize}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 8),
                    if (meal.status == 'pending')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Pending', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacro('Cal', '${meal.calories}', Colors.red),
              _buildMacro('Pro', '${meal.protein}g', Colors.blue),
              _buildMacro('Carb', '${meal.carbs}g', Colors.orange),
              _buildMacro('Fat', '${meal.fats}g', Colors.yellow.shade700),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFoodScreen(foodData: meal.rawData),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _deleteMeal(meal.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacro(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, fontFamily: 'Montserrat')),
      ],
    );
  }

  Future<void> _deleteMeal(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food'),
        content: const Text('Are you sure you want to delete this food item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final apiClient = ApiClient();
      try {
        await apiClient.dio.delete('${ApiEndpoints.adminMeals}/$id');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food deleted'), backgroundColor: Colors.green),
        );
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}