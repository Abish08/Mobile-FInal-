import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:nutri_nepal/screen/onboarding_screen_.dart';
import 'package:nutri_nepal/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:nutri_nepal/core/widgets/app_logo.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  // Widget build(BuildContext context) {
  //   return const Placeholder();
  // }
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.white, Color(0xFFF0F4F1)],
            center: Alignment.center,
            radius: 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(fullLogo: true, size: 180),
              const SizedBox(height: 8),
              const Text(
                'Your Journey to wellness',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
