import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'clinical_data_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
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
                child: const Icon(Icons.favorite,
                    color: Color(0xFF35E0D0), size: 90),
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
              const Spacer(flex: 2),
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
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
