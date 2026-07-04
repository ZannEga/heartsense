import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/assessment_provider.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HeartSenseApp());
}

class HeartSenseApp extends StatelessWidget {
  const HeartSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AssessmentProvider(),
      child: MaterialApp(
        title: 'HeartSense AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const WelcomeScreen(),
      ),
    );
  }
}
