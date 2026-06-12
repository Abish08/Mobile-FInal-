import 'package:flutter/material.dart';

class WeeklyMealPlanScreen extends StatelessWidget {
  const WeeklyMealPlanScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range
            const Text(
              'July 15 - 21',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontFamily: 'OpenSans',
              ),
            ),
            const SizedBox(height: 16),

            // Week Days
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildDayChip('MON', '15', isSelected: true),
                  _buildDayChip('TUE', '16'),
                  _buildDayChip('WED', '17'),
                  _buildDayChip('THU', '18'),
                  _buildDayChip('FRI', '19'),
                  _buildDayChip('SAT', '20'),
                  _buildDayChip('SUN', '21'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Calories Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'CALORIES',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1,840',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
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
                      _buildMacroItem('124g', 'PROTEIN'),
                      const SizedBox(height: 12),
                      _buildMacroItem('32g', 'FIBER'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Meals List
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

            _buildMealCard(
              'BREAKFAST',
              'Berry Chia Smoothie Bowl',
              '340 kcal • 08:30 AM',
              Icons.breakfast_dining,
              Colors.orange,
            ),
            const SizedBox(height: 12),

            _buildMealCard(
              'LUNCH',
              'Grilled Chicken & Quinoa',
              '520 kcal • 12:30 PM',
              Icons.lunch_dining,
              Colors.green,
            ),
            const SizedBox(height: 12),

            _buildMealCard(
              'SNACK',
              'Nut & Fruit Medley',
              '180 kcal • 04:00 PM',
              Icons.cookie,
              Colors.brown,
            ),
            const SizedBox(height: 12),

            _buildMealCard(
              'DINNER',
              'Lemon Herb Baked Salmon',
              '480 kcal • 07:30 PM',
              Icons.dinner_dining,
              Colors.blue,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFB85C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDayChip(String day, String date, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B4332) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white70 : const Color(0xFF6B7280),
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
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
            fontFamily: 'OpenSans',
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(String type, String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
}