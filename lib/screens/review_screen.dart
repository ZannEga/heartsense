import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/option_labels.dart';
import '../providers/assessment_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/section_card.dart';
import 'clinical_data_screen.dart';
import 'exercise_data_screen.dart';
import 'model_selection_screen.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssessmentProvider>();
    final data = provider.patientData;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('HeartSense AI'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Review Your Data',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.navy)),
                Text('Step 3 of 4',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtitleGray)),
              ],
            ),
            const SizedBox(height: 10),
            const StepProgressBar(currentStep: 3, totalSteps: 4),
            const SizedBox(height: 20),
            const Text(
              'Double check everything looks right before generating a '
              'prediction - tap "Edit" on any section to go back and fix it.',
              style: TextStyle(color: AppColors.subtitleGray, height: 1.4),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Clinical Data',
              children: [
                _ReviewRow('Age', '${data.age.round()}'),
                _ReviewRow('Sex', data.sex == 1 ? 'Male' : 'Female'),
                _ReviewRow('Chest Pain Type', OptionLabels.cp[data.cp]),
                _ReviewRow('Resting BP', '${data.restingBp.round()} mm Hg'),
                _ReviewRow('Cholesterol', '${data.cholesterol.round()} mg/dl'),
                _ReviewRow('Fasting Blood Sugar > 120',
                    data.highFastingBloodSugar ? 'Yes' : 'No'),
                _ReviewRow(
                    'Resting ECG', OptionLabels.restEcg[data.restEcg]),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ClinicalDataScreen()),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
            SectionCard(
              title: 'Exercise Data',
              children: [
                _ReviewRow(
                    'Max Heart Rate', '${data.maxHeartRate.round()} bpm'),
                _ReviewRow(
                    'Exercise Angina', data.exerciseAngina ? 'Yes' : 'No'),
                _ReviewRow('Oldpeak', data.oldpeak.toStringAsFixed(1)),
                _ReviewRow('Slope', OptionLabels.slope[data.slope]),
                _ReviewRow('Major Vessels (CA)', '${data.majorVessels}'),
                _ReviewRow('Thal', OptionLabels.thal[data.thal]),
                _ReviewRow('Max Heart Rate Reserve',
                    '${data.maxHeartRateReserve.round()}'),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ExerciseDataScreen()),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlueDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ModelSelectionScreen()),
                  );
                },
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text('Continue to Model Selection',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.subtitleGray)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.navy)),
        ],
      ),
    );
  }
}
