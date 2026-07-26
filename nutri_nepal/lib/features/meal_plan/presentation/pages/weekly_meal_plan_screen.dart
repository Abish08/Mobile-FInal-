import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/features/meal_plan/domain/entities/meal_plan_entity.dart';
import 'package:nutri_nepal/features/meal_plan/presentation/providers/meal_plan_provider.dart';

class WeeklyMealPlanScreen extends ConsumerStatefulWidget {
  const WeeklyMealPlanScreen({super.key});

  @override
  ConsumerState<WeeklyMealPlanScreen> createState() =>
      _WeeklyMealPlanScreenState();
}

class _WeeklyMealPlanScreenState extends ConsumerState<WeeklyMealPlanScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<MealPlanMeal> _allMeals = [];
  int _selectedDayIndex = 0;
  List<DateTime> _weekDays = [];

  static const List<String> _dayNames = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];
  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _generateWeekDays();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchMeals();
      }
    });
  }

  void _generateWeekDays() {
    final today = DateTime.now();
    _weekDays = List.generate(7, (index) {
      return DateTime(today.year, today.month, today.day + index);
    });
  }

  Future<void> _fetchMeals() async {
    setState(() => _isLoading = true);
    try {
      final meals = await ref.read(mealPlanProvider.notifier).loadMealPlan();
      if (meals != null && mounted) {
        setState(() {
          _allMeals = meals;
          _errorMessage = null;
          _isLoading = false;
        });
      } else if (mounted) {
        final providerState = ref.read(mealPlanProvider);
        setState(() {
          _errorMessage =
              providerState.error?.toString() ?? 'No meals planned yet';
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

  List<MealPlanMeal> get _selectedDayMeals {
    final selectedDate = _weekDays[_selectedDayIndex];
    return _allMeals.where((meal) {
      final date = meal.date;
      if (date == null) return false;
      return date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;
    }).toList();
  }

  int get _totalCalories =>
      _selectedDayMeals.fold<int>(0, (sum, meal) => sum + meal.calories);
  int get _totalProtein =>
      _selectedDayMeals.fold<int>(0, (sum, meal) => sum + meal.protein);
  int get _totalCarbs =>
      _selectedDayMeals.fold<int>(0, (sum, meal) => sum + meal.carbs);

  String _formatDay(DateTime date) => _dayNames[date.weekday - 1];
  String _formatDate(DateTime date) => '${date.day}';
  String _formatMonthRange() {
    if (_weekDays.isEmpty) return '';
    final start = _weekDays.first;
    final end = _weekDays.last;
    return '${_monthNames[start.month - 1]} ${start.day} - ${end.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Weekly Plan',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF1B4332),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B4332)),
            )
          : _errorMessage != null
          ? _buildErrorPlanState(_errorMessage!)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'This Week',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        _formatMonthRange(),
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _weekDays.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedDayIndex == index;
                      final date = _weekDays[index];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDayIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 55,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1B4332)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF1B4332,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatDay(date),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white70
                                      : const Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(date),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchMeals,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1B4332,
                                  ).withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CALORIES',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        letterSpacing: 1.2,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$_totalCalories',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    const Text(
                                      '/ 2,200',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontFamily: 'OpenSans',
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    _buildMacroItem(
                                      '$_totalProtein g',
                                      'PROTEIN',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildMacroItem('$_totalCarbs g', 'CARBS'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Today's Meals",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedDayMeals.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'No meals planned for this day',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._selectedDayMeals.map(
                              (meal) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildMealCard(meal),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add Meal feature coming soon!'),
              backgroundColor: Color(0xFFB85C00),
            ),
          );
        },
        backgroundColor: const Color(0xFFB85C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMacroItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            letterSpacing: 0.5,
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(MealPlanMeal meal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_outlined,
              color: Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.category.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${meal.calories} kcal - ${meal.protein}g Protein',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontFamily: 'OpenSans',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }

  Widget _buildErrorPlanState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 36),
            const SizedBox(height: 12),
            const Text(
              'Weekly plan could not load',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMeals,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4332),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
