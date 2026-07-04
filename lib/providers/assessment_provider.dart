import 'package:flutter/foundation.dart';
import '../models/patient_data.dart';
import '../services/feature_scaler.dart';
import '../services/tflite_service.dart';

class AssessmentProvider extends ChangeNotifier {
  final PatientData patientData = PatientData();
  MlModelType selectedModel = MlModelType.mlp;

  bool isLoading = false;
  String? errorMessage;

  double? rawRiskScore; // actual "Heart Disease Risk Score" units (~7.5-18.8)
  double? riskPercent; // 0-100, for the results gauge (display only)
  String? riskLabel;
  String? riskSummary;

  void selectModel(MlModelType type) {
    selectedModel = type;
    notifyListeners();
  }

  /// Call after mutating any field on [patientData] directly (PatientData
  /// is a plain model, not a ChangeNotifier, to keep it simple).
  void notifyChanged() => notifyListeners();

  Future<void> runPrediction() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await TfliteService.instance.loadModels();

      // Same feature vector + same scaler for both models (they share the
      // exact preprocessing pipeline from UAS_MLPrak-main) - only the
      // chosen interpreter differs.
      final raw = patientData.toFeatureVector();
      final scaled = FeatureScaler.standardize(raw);
      final score =
          await TfliteService.instance.predictRaw(scaled, selectedModel);
      final percent = FeatureScaler.scoreToPercent(score);

      rawRiskScore = score;
      riskPercent = percent;

      if (percent >= 60) {
        riskLabel = 'Elevated Risk';
        riskSummary =
            'Your predicted risk score is on the higher end of the range seen '
            'in the training data, driven by the combination of vitals and '
            'exercise-test results you entered.';
      } else if (percent >= 30) {
        riskLabel = 'Moderate Risk';
        riskSummary =
            'Your predicted risk score sits in the middle of the range seen '
            'in the training data. Consider discussing these metrics with a '
            'doctor.';
      } else {
        riskLabel = 'Low Risk';
        riskSummary =
            'Your predicted risk score is on the lower end of the range seen '
            'in the training data.';
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    rawRiskScore = null;
    riskPercent = null;
    riskLabel = null;
    riskSummary = null;
    errorMessage = null;
    notifyListeners();
  }
}
