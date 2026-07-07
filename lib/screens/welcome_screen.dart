import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../theme/app_theme.dart';
import 'clinical_data_screen.dart';
import 'history_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Saved Data?'),
        content: const Text(
          'This removes all previously entered clinical data from this '
          'device. Your assessment history is kept separately and won\'t '
          'be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear',
                style: TextStyle(color: AppColors.riskOrange)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AssessmentProvider>().clearSavedInputs();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved data cleared.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF4F6FC),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                // Swap this Icon for Image.asset('assets/images/heart.png')
                // if you want the exact glowing 3D heart illustration.
                child: Image.asset('assets/images/heart_logo.png'),
              ),
              const SizedBox(height: 40),
              const Text(
                'Clarity and control for your heart health journey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Get instant insights into your cardiovascular health. '
                'Start your personalized heart health assessment now.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, color: AppColors.subtitleGray, height: 1.4),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlueDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ClinicalDataScreen()),
                    );
                  },
                  child: const Text(
                    'Start Assessment',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('View History'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _confirmClearData(context),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Clear Saved Data'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.subtitleGray),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'This app is for educational purposes only and is not a '
                'substitute for professional medical advice, diagnosis, or '
                'treatment.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.subtitleGray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
