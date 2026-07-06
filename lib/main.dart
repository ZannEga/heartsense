import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/assessment_provider.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Required before touching any platform channel (shared_preferences
  // uses one) prior to runApp().
  WidgetsFlutterBinding.ensureInitialized();

  final assessmentProvider = AssessmentProvider();
  // Restore whatever the user last entered on this device, if anything,
  // so the input screens come back pre-filled.
  await assessmentProvider.loadSavedData();

  runApp(HeartSenseApp(assessmentProvider: assessmentProvider));
}

class HeartSenseApp extends StatelessWidget {
  final AssessmentProvider assessmentProvider;

  const HeartSenseApp({super.key, required this.assessmentProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: assessmentProvider,
      child: MaterialApp(
        title: 'HeartSense AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const WelcomeScreen(),
      ),
    );
  }
}
