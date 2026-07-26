import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'OpenSans',
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B4332),
        primary: const Color(0xFF1B4332),
        secondary: const Color(0xFFB85C00),
        surface: Colors.white,
        background: const Color(0xFFF8F9FA),
      ),
      
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
        bodyLarge: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 16,
          color: Color(0xFF6B7280),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14,
          color: Color(0xFF6B7280),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB85C00),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1B4332),
        unselectedItemColor: Color(0xFF6B7280),
        type: BottomNavigationBarType.fixed,
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFB85C00),
        foregroundColor: Colors.white,
      ),
    );
  }
}