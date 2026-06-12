// import 'package:flutter/material.dart';

// class DashboardView extends StatefulWidget {
//   const DashboardView({super.key});

//   @override
//   State<DashboardView> createState() => _DashboardViewState();
// }

// class _DashboardViewState extends State<DashboardView> {
//   int _selectedIndex = 0;

//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const Center(child: Text('Meals Screen', style: TextStyle(fontSize: 24))),
//     const Center(child: Text('Workouts Screen', style: TextStyle(fontSize: 24))),
//     const Center(child: Text('Log Screen', style: TextStyle(fontSize: 24))),
//     const Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24))),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) => setState(() => _selectedIndex = index),
//         type: BottomNavigationBarType.fixed, // Required for 5 tabs (Topic 5, p.69)
//         selectedItemColor: const Color(0xFF1B4332), // Green from theme
//         unselectedItemColor: const Color(0xFF6B7280), // Grey from theme
//         backgroundColor: Colors.white,
//         elevation: 8,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Meals'),
//           BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
//           BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Log'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }

// // 
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 1. HEADER
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: const [
//                       Text(
//                         'Namaste, Abish',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Montserrat',
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         "You're 62% towards your goal today",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF6B7280),
//                           fontFamily: 'OpenSans',
//                         ),
//                       ),
//                     ],
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: const Icon(Icons.notifications_outlined, size: 24),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),

//               // 2. BMI CARD
//               _buildBmiCard(),
//               const SizedBox(height: 16),

//               // 3. DAILY CALORIES CARD
//               _buildCaloriesCard(),
//               const SizedBox(height: 16),

//               // 4. MACROS ROW
//               _buildMacrosRow(),
//               const SizedBox(height: 24),

//               // 5. DAILY AGENDA
//               const Text(
//                 'Daily Agenda',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Montserrat',
//                 ),
//               ),
//               const SizedBox(height: 16),

//               _buildAgendaCard(
//                 icon: Icons.restaurant,
//                 iconColor: Colors.green,
//                 label: 'NEXT MEAL: LUNCH',
//                 title: 'Grilled Chicken Breast and Rice Bowl with veggies',
//                 subtitle: '480 kcal • High-Protein',
//               ),
//               const SizedBox(height: 12),

//               _buildAgendaCard(
//                 icon: Icons.fitness_center,
//                 iconColor: const Color(0xFF1B4332),
//                 label: 'DAILY MOVEMENT',
//                 title: 'Core Stability & HIIT',
//                 subtitle: '45 Minutes, Intermediate',
//               ),
//               const SizedBox(height: 80), // Space for FAB
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // BMI CARD
//   Widget _buildBmiCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: const [
//               Text(
//                 'YOUR BODY MASS INDEX',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: Color(0xFF6B7280),
//                   fontFamily: 'Montserrat',
//                 ),
//               ),
//               Text(
//                 '22.4',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1F2937),
//                   fontFamily: 'Montserrat',
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Stack(
//             children: [
//               Container(
//                 height: 8,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(4),
//                   gradient: const LinearGradient(
//                     colors: [
//                       Color(0xFF4CAF50), // Under
//                       Color(0xFF8BC34A), // Normal
//                       Color(0xFFFFC107), // Over
//                       Color(0xFFF44336), // Obese
//                     ],
//                   ),
//                 ),
//               ),
//               const Positioned(
//                 left: 120, // Normal range marker position (BMI 22.4)
//                 child: CircleAvatar(
//                   radius: 8,
//                   backgroundColor: Colors.white,
//                   child: CircleAvatar(
//                     radius: 6,
//                     backgroundColor: Color(0xFF1F2937),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: const [
//               Text('Under', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
//               Text('Normal', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
//               Text('Over', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
//               Text('Obese', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // CALORIES CARD
//   Widget _buildCaloriesCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Daily Calories',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               color: Colors.white,
//               fontFamily: 'Montserrat',
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Row(
//             crossAxisAlignment: CrossAxisAlignment.baseline,
//             textBaseline: TextBaseline.alphabetic,
//             children: [
//               Text(
//                 '1,842',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   fontFamily: 'Montserrat',
//                 ),
//               ),
//               SizedBox(width: 4),
//               Text(
//                 '/ 2,250 kcal',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white70,
//                   fontFamily: 'OpenSans',
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(4),
//             child: LinearProgressIndicator(
//               value: 0.82, // 1842/2250 = 0.82
//               backgroundColor: Colors.white24,
//               valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB85C00)),
//               minHeight: 8,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // MACROS ROW
//   Widget _buildMacrosRow() {
//     return Row(
//       children: [
//         Expanded(child: _buildMacroCard('Protein', '120g', Colors.green)),
//         const SizedBox(width: 12),
//         Expanded(child: _buildMacroCard('Carbs', '186g', const Color(0xFFB85C00))),
//         const SizedBox(width: 12),
//         Expanded(child: _buildMacroCard('Fats', '45g', Colors.blue)),
//       ],
//     );
//   }

//   Widget _buildMacroCard(String label, String value, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 width: 60,
//                 height: 60,
//                 child: CircularProgressIndicator(
//                   value: 0.7,
//                   strokeWidth: 6,
//                   backgroundColor: color.withOpacity(0.2),
//                   valueColor: AlwaysStoppedAnimation<Color>(color),
//                 ),
//               ),
//               Column(
//                 children: [
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                       fontFamily: 'Montserrat',
//                     ),
//                   ),
//                   Text(
//                     value,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[800],
//                       fontFamily: 'Montserrat',
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   //AGENDA CARDS
//   Widget _buildAgendaCard({
//     required IconData icon,
//     required Color iconColor,
//     required String label,
//     required String title,
//     required String subtitle,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: iconColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, size: 32, color: iconColor),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: iconColor,
//                     fontFamily: 'Montserrat',
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1F2937),
//                     fontFamily: 'Montserrat',
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Color(0xFF6B7280),
//                     fontFamily: 'OpenSans',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/weekly_meal_plan_screen.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/diet_recommendation_screen.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/workout_screen.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/daily_log_screen.dart';
import 'package:nutri_nepal/features/dashboard/presentation/pages/user_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const WeeklyMealPlanScreen(),
    const DietRecommendationScreen(),
    const WorkoutScreen(),
    const DailyLogScreen(),
    const UserProfileScreen(),
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