import 'package:flutter/material.dart';
import 'package:nutri_nepal/app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:nutri_nepal/features/meal_plan/domain/entities/meal_plan_entity.dart';
import 'package:nutri_nepal/features/meal_plan/presentation/providers/meal_plan_provider.dart';

class DietRecommendationScreen extends ConsumerStatefulWidget {
  const DietRecommendationScreen({super.key});

  @override
  ConsumerState<DietRecommendationScreen> createState() =>
      _DietRecommendationScreenState();
}

class _DietRecommendationScreenState
    extends ConsumerState<DietRecommendationScreen> {
  List<FoodItem> _allFoods = [];
  List<FoodItem> _filteredFoods = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedMealType = 'All';

  final List<String> _mealTypes = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchFoods();
      }
    });
  }

  Future<void> _fetchFoods() async {
    setState(() => _isLoading = true);
    try {
      final foods = await ref
          .read(mealPlanProvider.notifier)
          .loadRecommendations();
      if (foods != null && mounted) {
        setState(() {
          _allFoods = foods;
          _applyFilter();
          _errorMessage = null;
          _isLoading = false;
        });
      } else if (mounted) {
        final providerState = ref.read(mealPlanProvider);
        setState(() {
          _errorMessage = providerState.error?.toString() ?? 'No meals found';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    _filteredFoods = ref
        .read(mealPlanProvider.notifier)
        .filterFoods(_allFoods, _selectedMealType);
  }

  void _selectMealType(String type) {
    setState(() {
      _selectedMealType = type;
      _applyFilter();
    });
  }

  Future<void> _logMeal(FoodItem food) async {
    final authState = ref.read(authViewModelProvider);
    final userId = authState.user?.userId;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final logged = await ref
          .read(mealPlanProvider.notifier)
          .logRecommendedFood(food, _selectedMealType);
      if (logged) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${food.name} logged successfully!'),
              backgroundColor: AppColors.primaryOrange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          _fetchFoods();
        }
      } else {
        throw Exception(
          ref.read(mealPlanProvider).error ?? 'Could not log this meal',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Meals',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryOrange),
            onPressed: _fetchFoods,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          : _errorMessage != null
          ? _buildErrorMealsState(_errorMessage!)
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recommended for your fitness goal',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _mealTypes.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final type = _mealTypes[index];
                            final isSelected = _selectedMealType == type;
                            return GestureDetector(
                              onTap: () => _selectMealType(type),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryOrange
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryOrange
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.grey,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
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
                Expanded(
                  child: _filteredFoods.isEmpty
                      ? _buildEmptyMealsState()
                      : RefreshIndicator(
                          onRefresh: _fetchFoods,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredFoods.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) =>
                                _buildMealCard(_filteredFoods[index]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMealCard(FoodItem food) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                food.thumbnail != null
                    ? Image.network(
                        food.thumbnail!,
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.46),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${food.calories} kcal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatCategory(food.category),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryOrange,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Serving ${food.servingSize.toStringAsFixed(0)} g',
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 13,
                    fontFamily: 'OpenSans',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildMacroItem(
                        '${food.protein.toStringAsFixed(0)}g',
                        'Protein',
                        const Color(0xFF2563EB),
                      ),
                    ),
                    Expanded(
                      child: _buildMacroItem(
                        '${food.carbs.toStringAsFixed(0)}g',
                        'Carbs',
                        const Color(0xFF16A34A),
                      ),
                    ),
                    Expanded(
                      child: _buildMacroItem(
                        '${food.fats.toStringAsFixed(0)}g',
                        'Fats',
                        const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showMealDetails(food),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryOrange,
                          side: const BorderSide(
                            color: AppColors.primaryOrange,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _logMeal(food),
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Log meal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB85C00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
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
      height: 170,
      width: double.infinity,
      color: AppColors.surfaceSoft,
      child: const Icon(
        Icons.restaurant,
        size: 54,
        color: AppColors.primaryOrange,
      ),
    );
  }

  Widget _buildMacroItem(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.grey,
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMealsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: AppColors.primaryOrange,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No meals found',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try another meal type or refresh the list.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 13,
                fontFamily: 'OpenSans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMealsState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 36),
            const SizedBox(height: 12),
            const Text(
              'Meals could not load',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 13,
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchFoods,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMealDetails(FoodItem food) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.appBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              food.name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_formatCategory(food.category)} - ${food.servingSize.toStringAsFixed(0)} g serving',
              style: const TextStyle(
                color: AppColors.grey,
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 18),
            _buildDetailRow('Calories', '${food.calories} kcal'),
            _buildDetailRow('Protein', '${food.protein.toStringAsFixed(0)} g'),
            _buildDetailRow('Carbs', '${food.carbs.toStringAsFixed(0)} g'),
            _buildDetailRow('Fats', '${food.fats.toStringAsFixed(0)} g'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _logMeal(food);
                },
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Log meal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB85C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.grey,
              fontFamily: 'OpenSans',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  String _formatCategory(String category) {
    final clean = category.trim();
    if (clean.isEmpty) return 'Meal';
    if (clean.toLowerCase() == 'junk') return 'Occasional';
    return clean[0].toUpperCase() + clean.substring(1);
  }
}
