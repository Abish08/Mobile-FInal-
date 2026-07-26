import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_nepal/app/theme/app_theme.dart';
import 'package:nutri_nepal/app/routes/app_routes.dart';
import 'package:nutri_nepal/features/auth/presentation/pages/login_screen.dart';

class NutriNepalApp extends ConsumerWidget {
  const NutriNepalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriNepal',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
