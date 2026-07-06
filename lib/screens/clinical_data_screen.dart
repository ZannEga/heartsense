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
import 'exercise_data_screen.dart';

class ClinicalDataScreen extends StatefulWidget {
  const ClinicalDataScreen({super.key});

  @override
  State<ClinicalDataScreen> createState() => _ClinicalDataScreenState();
}

class _ClinicalDataScreenState extends State<ClinicalDataScreen> {
  late TextEditingController _bpController;
  late TextEditingController _cholController;

  String? _bpError;
  String? _cholError;

  @override
  void initState() {
    super.initState();
    final data = context.read<AssessmentProvider>().patientData;
    _bpController = TextEditingController(text: data.restingBp.toStringAsFixed(0));
    _cholController = TextEditingController(text: data.cholesterol.toStringAsFixed(0));
    // Validate the pre-filled/restored values immediately.
    _bpError = Validators.restingBp(_bpController.text);
    _cholError = Validators.cholesterol(_cholController.text);
  }

  @override
  void dispose() {
    _bpController.dispose();
    _cholController.dispose();
    super.dispose();
  }

  bool get _isValid => _bpError == null && _cholError == null;

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
                Text('Clinical Data',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.navy)),
                Text('Step 1 of 4',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtitleGray)),
              ],
            ),
            const SizedBox(height: 10),
            const StepProgressBar(currentStep: 1, totalSteps: 4),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Patient Profile',
              children: [
                Text('Age', style: Theme.of(context).textTheme.bodyMedium),
                Text('${data.age.round()}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Slider(
                  value: data.age,
                  min: 18,
                  max: 100,
                  activeColor: AppColors.primaryBlue,
                  inactiveColor: AppColors.trackBlue,
                  onChanged: (v) {
                    data.age = v;
                    provider.notifyChanged();
                  },
                ),
                const SizedBox(height: 8),
                const Text('Biological Sex',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _SexButton(
                        label: 'Male',
                        selected: data.sex == 1,
                        onTap: () {
                          data.sex = 1;
                          provider.notifyChanged();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SexButton(
                        label: 'Female',
                        selected: data.sex == 0,
                        onTap: () {
                          data.sex = 0;
                          provider.notifyChanged();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SectionCard(
              title: 'Symptoms & Vitals',
              children: [
                const InfoLabel(
                  label: 'Chest Pain Type (CP)',
                  info: 'Typical Angina: classic chest pain triggered by '
                      'exertion or stress.\n'
                      'Atypical Angina: chest pain that doesn\'t fully fit '
                      'the typical pattern.\n'
                      'Non-anginal Pain: chest pain likely unrelated to the '
                      'heart.\n'
                      'Asymptomatic: no chest pain reported.',
                ),
                const SizedBox(height: 8),
                LabeledDropdown(
                  value: OptionLabels.cp[data.cp],
                  items: OptionLabels.cp,
                  onChanged: (v) {
                    data.cp = OptionLabels.cp.indexOf(v!);
                    provider.notifyChanged();
                  },
                ),
                const SizedBox(height: 16),
                const Text('Resting Blood Pressure (mm Hg)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                NumericField(
                  controller: _bpController,
                  errorText: _bpError,
                  onChanged: (v) {
                    setState(() => _bpError = Validators.restingBp(v));
                    final parsed = double.tryParse(v);
                    if (parsed != null) {
                      data.restingBp = parsed;
                      provider.notifyChanged();
                    }
                  },
                ),
              ],
            ),
            SectionCard(
              title: 'Lab Results',
              children: [
                const Text('Serum Cholesterol (mg/dl)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                NumericField(
                  controller: _cholController,
                  errorText: _cholError,
                  onChanged: (v) {
                    setState(() => _cholError = Validators.cholesterol(v));
                    final parsed = double.tryParse(v);
                    if (parsed != null) {
                      data.cholesterol = parsed;
                      provider.notifyChanged();
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                        child: Text('Fasting Blood Sugar > 120 mg/dl',
                            style: TextStyle(fontWeight: FontWeight.w600))),
                    Switch(
                      value: data.highFastingBloodSugar,
                      activeColor: AppColors.primaryBlue,
                      onChanged: (v) {
                        data.highFastingBloodSugar = v;
                        provider.notifyChanged();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const InfoLabel(
                  label: 'Resting Electrocardiographic Results',
                  info: 'Normal: no abnormalities detected at rest.\n'
                      'ST-T Wave Abnormality: minor irregularities in the '
                      'heart\'s electrical pattern.\n'
                      'Left Ventricular Hypertrophy: signs of a thickened '
                      'heart muscle wall.',
                ),
                const SizedBox(height: 8),
                LabeledDropdown(
                  value: OptionLabels.restEcg[data.restEcg],
                  items: OptionLabels.restEcg,
                  onChanged: (v) {
                    data.restEcg = OptionLabels.restEcg.indexOf(v!);
                    provider.notifyChanged();
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
                              builder: (_) => const ExerciseDataScreen()),
                        );
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text('Continue to Exercise Data',
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

class _SexButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SexButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.primaryBlue : Colors.white,
        side: BorderSide(
            color: selected ? AppColors.primaryBlue : AppColors.borderGray),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Text(label,
          style: TextStyle(
              color: selected ? Colors.white : AppColors.navy,
              fontWeight: FontWeight.w600)),
    );
  }
}
