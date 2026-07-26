import 'package:flutter/material.dart';
import 'package:nutri_nepal/theme/theme.dart';
import 'package:nutri_nepal/screen/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriNepal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashView(),
    );
  }
}