import 'package:flutter/material.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/user_dashboard_screen.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/diet_recommendation_screen.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/workout_screen.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/daily_log_screen.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/user_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const UserDashboardScreen(),        // ✅ Tab 0: Home
    const DietRecommendationScreen(),   // ✅ Tab 1: Meals
    const WorkoutScreen(),              // ✅ Tab 2: Workouts
    const DailyLogScreen(),             // ✅ Tab 3: Log
    const UserProfileScreen(),          // ✅ Tab 4: Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
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