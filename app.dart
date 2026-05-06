import 'package:flutter/material.dart';
import 'package:nutri_nepal/views/splash_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriNepal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4332)),
          useMaterial3: true,
      ),
      home: const SplashView(),
    );
  }
}