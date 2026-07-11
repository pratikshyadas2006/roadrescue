import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/screens/splash_screen.dart';

void main() {
  runApp(const RoadRescueApp());
}

class RoadRescueApp extends StatelessWidget {
  const RoadRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Road Rescue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.emergencyRed,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}