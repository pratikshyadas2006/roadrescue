import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/screens/splash_screen.dart';
import 'package:rr/l10n/app_localizations.dart';
import 'package:rr/providers/locale_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const RoadRescueApp(),
    ),
  );
}

class RoadRescueApp extends StatelessWidget {
  const RoadRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to current locale state changes
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Road Rescue',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: AppLocalizations.supportedLocales,
      
      // Dynamically updates based on provider selection
      locale: localeProvider.locale,

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