import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../services/pdf_report_service.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssessmentProvider>();
    final data = provider.patientData;
    final percent = provider.riskPercent ?? 0;
    final now = TimeOfDay.now();

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
            const Center(
              child: Text('Assessment Results',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text('Generated today at ${now.format(context)}',
                  style: const TextStyle(color: AppColors.subtitleGray)),
            ),
            const SizedBox(height: 20),

            if (provider.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.riskOrangeBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Prediction failed: ${provider.errorMessage}',
                  style: const TextStyle(color: AppColors.riskOrange),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: percent),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedPercent, child) {
                        return SizedBox(
                          width: 220,
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 220,
                                height: 220,
                                child: CircularProgressIndicator(
                                  value: animatedPercent / 100,
                                  strokeWidth: 16,
                                  backgroundColor: AppColors.trackBlue,
                                  valueColor: AlwaysStoppedAnimation(
                                      _riskColor(animatedPercent)),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${animatedPercent.round()}%',
                                      style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.navy)),
                                  const Text('RISK SCORE',
                                      style: TextStyle(
                                          color: AppColors.subtitleGray,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: AppColors.riskOrangeBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: _riskColor(percent), size: 18),
                          const SizedBox(width: 6),
                          Text(provider.riskLabel ?? '-',
                              style: TextStyle(
                                  color: _riskColor(percent),
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      provider.riskSummary ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.subtitleGray, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    // Transparency: the model itself outputs a raw
                    // "Heart Disease Risk Score", the % above is just a
                    // display-friendly normalization of that value.
                    Text(
                      'Raw model score: ${provider.rawRiskScore?.toStringAsFixed(2) ?? '-'} '
                      '(training data range ~7.5-18.8)',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.subtitleGray),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.favorite_border,
                      label: 'Resting BP',
                      value: '${data.restingBp.round()} mm Hg',
                      trailing: 'Systolic',
                      trailingColor: AppColors.subtitleGray,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.water_drop_outlined,
                      label: 'Cholesterol',
                      value: '${data.cholesterol.round()} mg/dL',
                      trailing: 'Serum',
                      trailingColor: AppColors.subtitleGray,
                    ),
                  ),
                ],
              ),
            ],

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
                onPressed: () {
                  provider.reset();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('Restart',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderGray),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () async {
                  final modelName =
                      provider.selectedModel.name == 'mlp' ? 'MLP' : 'TabNet';
                  await PdfReportService.printSingleResult(
                    data: data,
                    modelName: modelName,
                    percent: percent,
                    rawScore: provider.rawRiskScore ?? 0,
                    riskLabel: provider.riskLabel ?? '-',
                  );
                },
                icon: const Icon(Icons.print_outlined,
                    color: AppColors.primaryBlue),
                label: const Text('Print Summary for Doctor',
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),
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
    );
  }

  Color _riskColor(double percent) {
    if (percent >= 60) return AppColors.riskOrange;
    if (percent >= 30) return const Color(0xFFD9A400);
    return AppColors.tagGreenText;
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String trailing;
  final Color trailingColor;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.trailing,
    required this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.subtitleGray),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.subtitleGray,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy)),
          const SizedBox(height: 4),
          Text(trailing,
              style: TextStyle(
                  color: trailingColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
