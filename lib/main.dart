import 'package:flutter/material.dart';
import 'models/language_model.dart';
import 'services/onboarding_service.dart';
import 'theme/app_colors.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const DiakslangueApp());
}

class DiakslangueApp extends StatelessWidget {
  const DiakslangueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diakslangue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
        scaffoldBackgroundColor: AppColors.lightGrey,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.skyBlue,
          foregroundColor: AppColors.navy,
          elevation: 0,
        ),
      ),
      home: const _StartupGate(),
    );
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LanguageModel?>(
      future: OnboardingService.getMainLanguage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.lightGrey,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final mainLanguage = snapshot.data;
        if (mainLanguage != null) {
          return MainShell(initialLanguage: mainLanguage);
        }
        return const SplashScreen();
      },
    );
  }
}
