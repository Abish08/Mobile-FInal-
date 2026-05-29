import 'package:flutter/material.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Meals Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Workouts Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Log Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B4332),
        unselectedItemColor: const Color(0xFF6B7280),
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Meals'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

//HomeScreen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1️ HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Namaste, Arpan',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "You're 62% towards your goal today",
                        style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontFamily: 'OpenSans'),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(Icons.notifications_outlined, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2️ BMI CARD
              _buildBmiCard(),

              const SizedBox(height: 16),
              // ✅ Next step will replace this placeholder
              const Center(child: Text('Next: Daily Calories Card', style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      ),
    );
  }

  // BMI CARD WIDGET
  Widget _buildBmiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'YOUR BODY MASS INDEX',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6B7280), fontFamily: 'Montserrat'),
              ),
              Text(
                '22.4',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), fontFamily: 'Montserrat'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A), Color(0xFFFFC107), Color(0xFFF44336)],
                  ),
                ),
              ),
              const Positioned(
                left: 120,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(radius: 6, backgroundColor: Color(0xFF1F2937)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Under', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
              Text('Normal', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
              Text('Over', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
              Text('Obese', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
    );
  }
}