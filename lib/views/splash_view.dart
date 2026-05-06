import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nutri_nepal/views/onboarding_view.dart';

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
  void initState(){
    super.initState();
     Timer(const Duration(seconds: 2), () {
      if(!mounted) return;
      Navigator.pushReplacement(context,
       MaterialPageRoute(builder: (_)=> const OnboardingView()),
       );
  });
}
@override
  Widget build(BuildContext context){
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1B4332),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.local_florist,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16,),
            const Text(
              'NutriNepal',
              style: TextStyle(
                color:  Color(0xFF1F2937),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8,),
            const Text(
              'Your Journey to wellness',
              style: TextStyle(
                color: Color(0xFF6B7280),
              ),
            )
          ],
        ),
      ),
      
      )
    );
  }
}