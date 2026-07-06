import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../services/pdf_report_service.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

class CompareResultsScreen extends StatelessWidget {
  const CompareResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssessmentProvider>();
    final mlp = provider.mlpResult;
    final tabnet = provider.tabnetResult;

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
              child: Text('MLP vs TabNet',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text('Same input data, run through both models',
                  style: TextStyle(color: AppColors.subtitleGray)),
            ),
            const SizedBox(height: 20),
            _ModelResultCard(modelName: 'MLP Neural Net', result: mlp),
            const SizedBox(height: 16),
            _ModelResultCard(modelName: 'TabNet Analytics', result: tabnet),
            if (mlp != null &&
                tabnet != null &&
                !mlp.hasError &&
                !tabnet.hasError) ...[
              const SizedBox(height: 16),
              _DifferenceCard(mlp: mlp, tabnet: tabnet),
            ],
            const SizedBox(height: 24),
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
                  final rows = <PdfResultRow>[];
                  if (mlp != null && !mlp.hasError) {
                    rows.add(PdfResultRow(
                        'MLP', mlp.percent!, mlp.rawScore!, mlp.label!));
                  }
                  if (tabnet != null && !tabnet.hasError) {
                    rows.add(PdfResultRow('TabNet', tabnet.percent!,
                        tabnet.rawScore!, tabnet.label!));
                  }
                  if (rows.isEmpty) return;
                  await PdfReportService.printComparison(
                    data: provider.patientData,
                    rows: rows,
                  );
                },
                icon: const Icon(Icons.print_outlined,
                    color: AppColors.primaryBlue),
                label: const Text('Print Comparison for Doctor',
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
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
          ],
        ),
      ),
    );
  }
}

class _ModelResultCard extends StatelessWidget {
  final String modelName;
  final ModelResultData? result;

  const _ModelResultCard({required this.modelName, required this.result});

  Color _riskColor(double percent) {
    if (percent >= 60) return AppColors.riskOrange;
    if (percent >= 30) return const Color(0xFFD9A400);
    return AppColors.tagGreenText;
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return _card(
        child: const Text('Not run.', style: TextStyle(color: AppColors.subtitleGray)),
      );
    }

    if (result!.hasError) {
      final friendly = result!.error!.contains('not found')
          ? 'Model file not added yet (see README - run '
              'tools/convert_tabnet_to_tflite.py for TabNet).'
          : 'Prediction failed: ${result!.error}';
      return _card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: AppColors.riskOrange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(friendly,
                  style: const TextStyle(color: AppColors.riskOrange)),
            ),
          ],
        ),
      );
    }

    final percent = result!.percent!;
    final color = _riskColor(percent);

    return _card(
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 8,
                    backgroundColor: AppColors.trackBlue,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Text('${percent.round()}%',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result!.label!,
                    style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 4),
                Text('Raw score: ${result!.rawScore!.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.subtitleGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(modelName,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DifferenceCard extends StatelessWidget {
  final ModelResultData mlp;
  final ModelResultData tabnet;

  const _DifferenceCard({required this.mlp, required this.tabnet});

  @override
  Widget build(BuildContext context) {
    final diff = (mlp.percent! - tabnet.percent!).abs();
    final higher = mlp.percent! > tabnet.percent! ? 'MLP' : 'TabNet';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tagBluebg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.insights, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              diff < 1
                  ? 'Both models agree closely on this input (within 1%).'
                  : '$higher predicted a ${diff.round()}% higher risk score '
                      'than the other model for the same input.',
              style: const TextStyle(color: AppColors.navy, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
