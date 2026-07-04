import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final filled = i < currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 6),
            height: 6,
            decoration: BoxDecoration(
              color: filled ? AppColors.primaryBlue : AppColors.trackBlue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
