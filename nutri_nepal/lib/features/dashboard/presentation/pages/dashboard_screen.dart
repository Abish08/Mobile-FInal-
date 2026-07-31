import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/app/theme/app_colors.dart';
import 'package:nutri_nepal/core/providers/refresh_provider.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/user_dashboard_screen.dart';
import 'package:nutri_nepal/features/daily_log/presentation/pages/daily_log_screen.dart';
import 'package:nutri_nepal/features/meal_plan/presentation/pages/diet_recommendation_screen.dart';
import 'package:nutri_nepal/features/profile/presentation/pages/profile_screen.dart';
import 'package:nutri_nepal/features/progress/presentation/pages/progress_tracker_screen.dart';
import 'package:nutri_nepal/features/workouts/presentation/pages/workout_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0 || index == 3 || index == 4) {
      ref.read(refreshProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      UserDashboardScreen(onSelectTab: _selectTab),
      const DietRecommendationScreen(),
      const WorkoutScreen(),
      const DailyLogScreen(),
      const ProgressTrackerScreen(),
      const UserProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _selectTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.grey,
        backgroundColor: AppColors.appBackground,
        elevation: 12,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        showUnselectedLabels: false,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(fontFamily: 'OpenSans'),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            activeIcon: Icon(Icons.restaurant),
            label: 'Meals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
