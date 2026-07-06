import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../services/tflite_service.dart';
import '../theme/app_theme.dart';
import '../widgets/step_progress_bar.dart';
import 'compare_results_screen.dart';
import 'results_screen.dart';

class ModelSelectionScreen extends StatelessWidget {
  const ModelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssessmentProvider>();

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
            const StepProgressBar(currentStep: 4, totalSteps: 4),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('STEP 4 OF 4',
                  style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(height: 12),
            const Text('Select Analytical Model',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy)),
            const SizedBox(height: 8),
            const Text(
              'Choose the artificial intelligence framework to process your '
              'cardiovascular data. Both provide highly accurate clinical '
              'insights tailored to your inputs.',
              style: TextStyle(color: AppColors.subtitleGray, height: 1.4),
            ),
            const SizedBox(height: 20),
            _ModelCard(
              icon: Icons.hub_outlined,
              title: 'MLP Neural Net',
              description:
                  'A robust Deep Learning Multi-Layer Perceptron. Best for '
                  'discovering complex, non-linear patterns across varied '
                  'physiological signals.',
              tags: const [
                ('Deep Learning', AppColors.tagBluebg, AppColors.primaryBlue),
                ('High Precision', AppColors.tagGreenBg, AppColors.tagGreenText),
              ],
              selected: provider.selectedModel == MlModelType.mlp,
              onTap: () => provider.selectModel(MlModelType.mlp),
            ),
            const SizedBox(height: 16),
            _ModelCard(
              icon: Icons.table_chart_outlined,
              title: 'TabNet Analytics',
              description:
                  'A specialized architecture optimized for tabular health '
                  'records. Offers high interpretability, revealing exactly '
                  'which metrics drove the assessment.',
              tags: const [
                ('Structured Data', AppColors.tagBluebg, AppColors.primaryBlue),
                ('Highly Interpretable', AppColors.tagBluebg, AppColors.primaryBlue),
              ],
              selected: provider.selectedModel == MlModelType.tabnet,
              onTap: () => provider.selectModel(MlModelType.tabnet),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.tagBluebg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Clinical Note',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy)),
                        SizedBox(height: 4),
                        Text(
                          'Both models have been trained on verified clinical '
                          'datasets and validated for assessment accuracy. If '
                          'you are unsure, MLP is the recommended default for '
                          'general diagnostics.',
                          style: TextStyle(
                              color: AppColors.subtitleGray,
                              fontSize: 13,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlueDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        await provider.runPrediction();
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ResultsScreen()),
                          );
                        }
                      },
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 18),
                label: Text(
                  provider.isLoading ? 'Generating...' : 'Generate Prediction',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        await provider.runComparison();
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CompareResultsScreen()),
                          );
                        }
                      },
                icon: const Icon(Icons.compare_arrows,
                    color: AppColors.primaryBlue, size: 20),
                label: const Text(
                  'Compare Both Models',
                  style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<(String, Color, Color)> tags;
  final bool selected;
  final VoidCallback onTap;

  const _ModelCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.tags,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.borderGray,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.tagBluebg,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: AppColors.primaryBlue),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color:
                      selected ? AppColors.primaryBlue : AppColors.borderGray,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy)),
            const SizedBox(height: 8),
            Text(description,
                style:
                    const TextStyle(color: AppColors.subtitleGray, height: 1.4)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: tags.map((t) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: t.$2, borderRadius: BorderRadius.circular(20)),
                  child: Text(t.$1,
                      style: TextStyle(
                          color: t.$3,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
