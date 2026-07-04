import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assessment_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/section_card.dart';
import '../widgets/labeled_dropdown.dart';
import '../widgets/numeric_field.dart';
import 'model_selection_screen.dart';

class ExerciseDataScreen extends StatefulWidget {
  const ExerciseDataScreen({super.key});

  @override
  State<ExerciseDataScreen> createState() => _ExerciseDataScreenState();
}

class _ExerciseDataScreenState extends State<ExerciseDataScreen> {
  late TextEditingController _hrController;
  late TextEditingController _oldpeakController;
  late TextEditingController _hrReserveController;

  static const slopeOptions = ['Upsloping', 'Flat', 'Downsloping'];

  // 'ca' has 5 categories in heartv1.csv (0-4), not the standard UCI 0-3.
  static const vesselOptions = ['0', '1', '2', '3', '4'];

  // 'thal' has 4 categories in heartv1.csv (0-3). The dataset doesn't
  // document what each code means, so plain category labels are used
  // instead of guessing clinical names - rename these if you have a data
  // dictionary for heartv1.csv.
  static const thalOptions = ['Category 0', 'Category 1', 'Category 2', 'Category 3'];

  @override
  void initState() {
    super.initState();
    final data = context.read<AssessmentProvider>().patientData;
    _hrController =
        TextEditingController(text: data.maxHeartRate.toStringAsFixed(0));
    _oldpeakController =
        TextEditingController(text: data.oldpeak.toStringAsFixed(1));
    _hrReserveController =
        TextEditingController(text: data.maxHeartRateReserve.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _hrController.dispose();
    _oldpeakController.dispose();
    _hrReserveController.dispose();
    super.dispose();
  }

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
                Text('Exercise Data',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.navy)),
                Text('Step 2 of 3',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtitleGray)),
              ],
            ),
            const SizedBox(height: 10),
            const StepProgressBar(currentStep: 2, totalSteps: 3),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Exercise Test',
              children: [
                const Text('Max Heart Rate Achieved',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                NumericField(
                  controller: _hrController,
                  onChanged: (v) => data.maxHeartRate =
                      double.tryParse(v) ?? data.maxHeartRate,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                        child: Text('Exercise-Induced Angina',
                            style: TextStyle(fontWeight: FontWeight.w600))),
                    Switch(
                      value: data.exerciseAngina,
                      activeColor: AppColors.primaryBlue,
                      onChanged: (v) {
                        data.exerciseAngina = v;
                        provider.notifyChanged();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('ST Depression (Oldpeak)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                NumericField(
                  controller: _oldpeakController,
                  onChanged: (v) =>
                      data.oldpeak = double.tryParse(v) ?? data.oldpeak,
                ),
              ],
            ),
            SectionCard(
              title: 'Diagnostic Results',
              children: [
                const Text('Slope of Peak Exercise ST Segment',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                LabeledDropdown(
                  value: slopeOptions[data.slope],
                  items: slopeOptions,
                  onChanged: (v) {
                    data.slope = slopeOptions.indexOf(v!);
                    provider.notifyChanged();
                  },
                ),
                const SizedBox(height: 16),
                const Text('Number of Major Vessels (CA)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                LabeledDropdown(
                  value: vesselOptions[data.majorVessels],
                  items: vesselOptions,
                  onChanged: (v) {
                    data.majorVessels = int.parse(v!);
                    provider.notifyChanged();
                  },
                ),
                const SizedBox(height: 16),
                const Text('Thalassemia (Thal)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                LabeledDropdown(
                  value: thalOptions[data.thal],
                  items: thalOptions,
                  onChanged: (v) {
                    data.thal = thalOptions.indexOf(v!);
                    provider.notifyChanged();
                  },
                ),
              ],
            ),
            SectionCard(
              title: 'Additional Info',
              children: [
                const Text('Max Heart Rate Reserve',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text(
                  "Not derivable from age/heart rate with a fixed formula in "
                  'this dataset - enter it directly (training data ranged '
                  'roughly -29 to 82).',
                  style: TextStyle(fontSize: 12, color: AppColors.subtitleGray),
                ),
                const SizedBox(height: 8),
                NumericField(
                  controller: _hrReserveController,
                  onChanged: (v) => data.maxHeartRateReserve =
                      double.tryParse(v) ?? data.maxHeartRateReserve,
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
