import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';

class FoodItem {
  final String id;
  final String name;
  final String category;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final String? thumbnail;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.thumbnail,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    String? thumb;
    if (json['thumbnail'] != null) {
      thumb = json['thumbnail'];
    } else if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      thumb = (json['images'] as List)[0];
    }

    return FoodItem(
      id: json['_id'] is Map ? json['_id']['\$oid'] : json['_id'],
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? 'General',
      calories: (json['calories'] ?? 0).toInt(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fats: (json['fats'] ?? 0).toDouble(),
      thumbnail: thumb,
    );
  }
}

class DietRecommendationScreen extends ConsumerStatefulWidget {
  const DietRecommendationScreen({super.key});

  @override
  ConsumerState<DietRecommendationScreen> createState() => _DietRecommendationScreenState();
}

class _DietRecommendationScreenState extends ConsumerState<DietRecommendationScreen> {
  List<FoodItem> _allFoods = [];
  List<FoodItem> _filteredFoods = [];
  bool _isLoading = true;
  String _selectedMealType = 'All';

  final List<String> _mealTypes = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get(ApiEndpoints.publicFoods);

      if (response.statusCode == 200) {
        final List foodsData = response.data['foods'];
        setState(() {
          _allFoods = foodsData.map((e) => FoodItem.fromJson(e)).toList();
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching foods: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (_selectedMealType == 'All') {
      _filteredFoods = _allFoods;
    } else {
      _filteredFoods = _allFoods.where((food) {
        final category = food.category.toLowerCase();
        final mealType = _selectedMealType.toLowerCase();
        return category.contains(mealType);
      }).toList();
    }
  }

  void _selectMealType(String type) {
    setState(() {
      _selectedMealType = type;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Diet Plan',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1B4332)),
            onPressed: _fetchFoods,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
          : Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recommended for your fitness goal',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // ✅ FIXED: Scrollable meal type tabs
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _mealTypes.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final type = _mealTypes[index];
                            final isSelected = _selectedMealType == type;
                            return GestureDetector(
                              onTap: () => _selectMealType(type),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF1B4332) : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF1B4332) : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF1B4332).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ✅ FIXED: Scrollable food list
                Expanded(
                  child: _filteredFoods.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No meals found for $_selectedMealType',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchFoods,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredFoods.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final food = _filteredFoods[index];
                              return _buildEnhancedMealCard(food, isFeatured: index == 0);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEnhancedMealCard(FoodItem food, {bool isFeatured = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isFeatured ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isFeatured ? 0.1 : 0.05),
            blurRadius: isFeatured ? 20 : 10,
            offset: Offset(0, isFeatured ? 8 : 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(isFeatured ? 20 : 16)),
            child: Stack(
              children: [
                food.thumbnail != null
                    ? Image.network(
                        ApiEndpoints.resolveUploadUrl(food.thumbnail!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      food.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B4332),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: TextStyle(
                    fontSize: isFeatured ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Macros Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacroItem('${food.calories}', 'kcal', Colors.orange),
                    _buildMacroItem('${food.protein}g', 'protein', Colors.blue),
                    _buildMacroItem('${food.carbs}g', 'carbs', Colors.green),
                    _buildMacroItem('${food.fats}g', 'fats', Colors.red),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Log Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ ${food.name} logged successfully!'),
                          backgroundColor: const Color(0xFF1B4332),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB85C00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Log This Meal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFFF3F4F6),
      child: const Icon(
        Icons.restaurant,
        size: 80,
        color: Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildMacroItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFF6B7280),
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }
}