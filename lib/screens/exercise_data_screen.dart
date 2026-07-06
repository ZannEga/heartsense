import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/option_labels.dart';
import '../providers/assessment_provider.dart';
import '../services/validators.dart';
import '../theme/app_theme.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/section_card.dart';
import '../widgets/labeled_dropdown.dart';
import '../widgets/numeric_field.dart';
import '../widgets/info_label.dart';
import 'review_screen.dart';

class ExerciseDataScreen extends StatefulWidget {
  const ExerciseDataScreen({super.key});

  @override
  State<ExerciseDataScreen> createState() => _ExerciseDataScreenState();
}

class _ExerciseDataScreenState extends State<ExerciseDataScreen> {
  late TextEditingController _hrController;
  late TextEditingController _oldpeakController;
  late TextEditingController _hrReserveController;

  String? _hrError;
  String? _oldpeakError;
  String? _hrReserveError;

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

    _hrError = Validators.maxHeartRate(_hrController.text);
    _oldpeakError = Validators.oldpeak(_oldpeakController.text);
    _hrReserveError = Validators.maxHeartRateReserve(_hrReserveController.text);
  }

  @override
  void dispose() {
    _hrController.dispose();
    _oldpeakController.dispose();
    _hrReserveController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _hrError == null && _oldpeakError == null && _hrReserveError == null;

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
                Text('Step 2 of 4',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtitleGray)),
              ],
            ),
            const SizedBox(height: 10),
            const StepProgressBar(currentStep: 2, totalSteps: 4),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Exercise Test',
              children: [
                const Text('Max Heart Rate Achieved',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                NumericField(
                  controller: _hrController,
                  errorText: _hrError,
                  onChanged: (v) {
                    setState(() => _hrError = Validators.maxHeartRate(v));
                    final parsed = double.tryParse(v);
                    if (parsed != null) {
                      data.maxHeartRate = parsed;
                      provider.notifyChanged();
                    }
                  },
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
                InfoLabel(
                  label: 'ST Depression (Oldpeak)',
                  info:
                      'How much the ST segment of the heart\'s electrical '
                      'signal dips during exercise compared to rest, '
                      'measured on an ECG. A larger dip can indicate reduced '
                      'blood flow to the heart during exertion.',
                ),
                const SizedBox(height: 8),
                NumericField(
                  controller: _oldpeakController,
                  errorText: _oldpeakError,
                  onChanged: (v) {
                    setState(() => _oldpeakError = Validators.oldpeak(v));
                    final parsed = double.tryParse(v);
                    if (parsed != null) {
                      data.oldpeak = parsed;
                      provider.notifyChanged();
                    }
                  },
                ),
              ],
            ),
            SectionCard(
              title: 'Diagnostic Results',
              children: [
                InfoLabel(
                  label: 'Slope of Peak Exercise ST Segment',
                  info:
                      'The direction the ST segment trends during peak '
                      'exercise on an ECG - upsloping, flat, or downsloping. '
                      'A flat or downsloping pattern is more often '
                      'associated with reduced blood flow.',
                ),
                const SizedBox(height: 8),
                LabeledDropdown(
                  value: OptionLabels.slope[data.slope],
                  items: OptionLabels.slope,
                  onChanged: (v) {
                    data.slope = OptionLabels.slope.indexOf(v!);
                    provider.notifyChanged();
                  },
                ),
                const SizedBox(height: 16),
                InfoLabel(
                  label: 'Number of Major Vessels (CA)',
                  info:
                      'The number of major blood vessels (0-4) shown to be '
                      'colored/visible via fluoroscopy, a type of X-ray '
                      'imaging with a contrast dye. More visible vessels '
                      'generally indicates healthier blood flow.',
                ),
                const SizedBox(height: 8),
                LabeledDropdown(
                  value: OptionLabels.vessels[data.majorVessels],
                  items: OptionLabels.vessels,
                  onChanged: (v) {
                    data.majorVessels = int.parse(v!);
                    provider.notifyChanged();
                  },
                ),
                const SizedBox(height: 16),
                InfoLabel(
                  label: 'Thalassemia (Thal)',
                  info:
                      'A category from a blood-disorder screening test '
                      'related to how oxygen is carried in the blood. This '
                      'dataset doesn\'t document exactly what each numbered '
                      'category (0-3) represents - use whatever category '
                      'your own test results/report indicates.',
                ),
                const SizedBox(height: 8),
                LabeledDropdown(
                  value: OptionLabels.thal[data.thal],
                  items: OptionLabels.thal,
                  onChanged: (v) {
                    data.thal = OptionLabels.thal.indexOf(v!);
                    provider.notifyChanged();
                  },
                ),
              ],
            ),
            SectionCard(
              title: 'Additional Info',
              children: [
                InfoLabel(
                  label: 'Max Heart Rate Reserve',
                  info:
                      'Roughly how much "room" is left between your resting '
                      'heart rate and your theoretical maximum - a larger '
                      'reserve generally suggests better cardiovascular '
                      'fitness. Not derivable from age/heart rate with a '
                      'fixed formula in this dataset - enter it directly '
                      '(training data ranged roughly -29 to 82).',
                ),
                const SizedBox(height: 8),
                NumericField(
                  controller: _hrReserveController,
                  errorText: _hrReserveError,
                  onChanged: (v) {
                    setState(
                        () => _hrReserveError = Validators.maxHeartRateReserve(v));
                    final parsed = double.tryParse(v);
                    if (parsed != null) {
                      data.maxHeartRateReserve = parsed;
                      provider.notifyChanged();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isValid ? AppColors.primaryBlueDark : AppColors.borderGray,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _isValid
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ReviewScreen()),
                        );
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text('Review & Continue',
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
