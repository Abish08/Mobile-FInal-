import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';

class WeeklyMealPlanScreen extends ConsumerStatefulWidget {
  const WeeklyMealPlanScreen({super.key});

  @override
  ConsumerState<WeeklyMealPlanScreen> createState() => _WeeklyMealPlanScreenState();
}

class _WeeklyMealPlanScreenState extends ConsumerState<WeeklyMealPlanScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allMeals = [];
  int _selectedDayIndex = 0;
  List<DateTime> _weekDays = [];

  @override
  void initState() {
    super.initState();
    _generateWeekDays();
    _fetchMeals();
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
      final response = await ApiClient().dio.get(ApiEndpoints.meals);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data;
        setState(() {
          _allMeals = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching meals: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _selectedDayMeals {
    final selectedDate = _weekDays[_selectedDayIndex];
    return _allMeals.where((meal) {
      final dateStr = meal['createdAt'] ?? meal['date'];
      if (dateStr == null) return false;
      try {
        final date = DateTime.parse(dateStr.toString());
        return date.year == selectedDate.year && 
               date.month == selectedDate.month && 
               date.day == selectedDate.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  int get _totalCalories => _selectedDayMeals.fold<int>(0, (sum, meal) {
    final cals = meal['calories'];
    if (cals == null) return sum;
    final calValue = cals is int ? cals : (cals is double ? cals.toInt() : 0);
    return sum + calValue;
  });

  int get _totalProtein => _selectedDayMeals.fold<int>(0, (sum, meal) {
    final p = meal['protein'];
    if (p == null) return sum;
    final pValue = p is int ? p : (p is double ? p.toInt() : 0);
    return sum + pValue;
  });

  int get _totalCarbs => _selectedDayMeals.fold<int>(0, (sum, meal) {
    final c = meal['carbs'];
    if (c == null) return sum;
    final cValue = c is int ? c : (c is double ? c.toInt() : 0);
    return sum + cValue;
  });

  String _formatDay(DateTime date) {
    return DateFormat('EEE').format(date).toUpperCase();
  }

  String _formatDate(DateTime date) {
    return DateFormat('d').format(date);
  }

  String _formatMonthRange() {
    if (_weekDays.isEmpty) return '';
    final start = _weekDays.first;
    final end = _weekDays.last;
    return '${DateFormat('MMMM d').format(start)} - ${DateFormat('d').format(end)}';
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
            icon: const Icon(Icons.calendar_today, color: Color(0xFF1B4332)),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'This Week',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), fontFamily: 'Montserrat'),
                      ),
                      Text(
                        _formatMonthRange(),
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontFamily: 'OpenSans'),
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
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedDayIndex == index;
                      final date = _weekDays[index];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDayIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 55,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1B4332) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF1B4332).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_formatDay(date), style: TextStyle(color: isSelected ? Colors.white70 : const Color(0xFF6B7280), fontSize: 12, fontFamily: 'Montserrat')),
                              const SizedBox(height: 4),
                              Text(_formatDate(date), style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
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
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('CALORIES', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Montserrat')),
                                    const SizedBox(height: 8),
                                    Text('$_totalCalories', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
                                    const Text('/ 2,200', style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'OpenSans')),
                                  ],
                                ),
                                Column(
                                  children: [
                                    _buildMacroItem('$_totalProtein g', 'PROTEIN'),
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), fontFamily: 'Montserrat'),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedDayMeals.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: const Center(child: Text('No meals planned for this day', style: TextStyle(color: Color(0xFF6B7280)))),
                            )
                          else
                            ..._selectedDayMeals.map((meal) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildMealCard(meal),
                                )),
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
            const SnackBar(content: Text('Add Meal feature coming soon!'), backgroundColor: Color(0xFFB85C00)),
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
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'OpenSans')),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    final calories = meal['calories'] ?? 0;
    final protein = meal['protein'] ?? 0;
    final name = meal['name'] ?? 'Unknown Meal';
    final category = meal['category'] ?? 'Meal';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.restaurant, color: Colors.orange, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.toUpperCase(), style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Montserrat')),
                const SizedBox(height: 4),
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), fontFamily: 'Montserrat')),
                const SizedBox(height: 4),
                Text('$calories kcal • ${protein}g Protein', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontFamily: 'OpenSans')),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
        ],
      ),
    );
  }
}