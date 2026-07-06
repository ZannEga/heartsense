import 'package:flutter/foundation.dart';
import '../models/patient_data.dart';
import '../services/feature_scaler.dart';
import '../services/local_storage_service.dart';
import '../services/tflite_service.dart';

/// Result of running a single model, kept separate from the other model's
/// result so one failing (e.g. TabNet's .tflite not added yet) doesn't
/// block showing the other's result in Compare mode.
class ModelResultData {
  final double? percent;
  final double? rawScore;
  final String? label;
  final String? error;

  ModelResultData({this.percent, this.rawScore, this.label, this.error});

  bool get hasError => error != null;
}

class AssessmentProvider extends ChangeNotifier {
  final PatientData patientData = PatientData();
  MlModelType selectedModel = MlModelType.mlp;

  bool isLoading = false;
  String? errorMessage;

  double? rawRiskScore; // actual "Heart Disease Risk Score" units (~7.5-18.8)
  double? riskPercent; // 0-100, for the results gauge (display only)
  String? riskLabel;
  String? riskSummary;

  // Populated after runComparison().
  ModelResultData? mlpResult;
  ModelResultData? tabnetResult;

  /// Call once at app startup (before runApp - see main.dart) to restore
  /// whatever the user last entered, so fields come back pre-filled.
  Future<void> loadSavedData() async {
    final saved = await LocalStorageService.loadPatientData();
    if (saved != null) {
      patientData.copyFrom(saved);
    }
  }

  void selectModel(MlModelType type) {
    selectedModel = type;
    notifyListeners();
  }

  /// Call after mutating any field on [patientData] directly (PatientData
  /// is a plain model, not a ChangeNotifier, to keep it simple). Also
  /// persists to disk so the values survive the next app launch.
  void notifyChanged() {
    notifyListeners();
    // Fire-and-forget: keeps sliders/typing responsive. The payload is
    // tiny (14 fields), so this is cheap - add a debounce Timer here if
    // you ever see jank while dragging the age slider.
    LocalStorageService.savePatientData(patientData);
  }

  /// Wipes the saved inputs (both the in-memory form and the on-disk
  /// copy), resetting every field back to its default value.
  Future<void> clearSavedInputs() async {
    patientData.copyFrom(PatientData());
    await LocalStorageService.clear();
    notifyListeners();
  }

  String _labelFor(double percent) {
    if (percent >= 60) return 'Elevated Risk';
    if (percent >= 30) return 'Moderate Risk';
    return 'Low Risk';
  }

  String _summaryFor(double percent) {
    if (percent >= 60) {
      return 'Your predicted risk score is on the higher end of the range '
          'seen in the training data, driven by the combination of vitals '
          'and exercise-test results you entered.';
    } else if (percent >= 30) {
      return 'Your predicted risk score sits in the middle of the range '
          'seen in the training data. Consider discussing these metrics '
          'with a doctor.';
    }
    return 'Your predicted risk score is on the lower end of the range '
        'seen in the training data.';
  }

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
      riskLabel = _labelFor(percent);
      riskSummary = _summaryFor(percent);

      await LocalStorageService.addHistoryEntry(
        model: selectedModel == MlModelType.mlp ? 'MLP' : 'TabNet',
        percent: percent,
        rawScore: score,
        label: riskLabel!,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Runs BOTH models on the same input and stores each result
  /// independently, so if one fails (e.g. TabNet's .tflite hasn't been
  /// added yet) the other's result still shows.
  Future<void> runComparison() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await TfliteService.instance.loadModels();
      final raw = patientData.toFeatureVector();
      final scaled = FeatureScaler.standardize(raw);

      mlpResult = await _runSingleModel(scaled, MlModelType.mlp, 'MLP');
      tabnetResult =
          await _runSingleModel(scaled, MlModelType.tabnet, 'TabNet');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<ModelResultData> _runSingleModel(
    List<double> scaled,
    MlModelType type,
    String modelName,
  ) async {
    try {
      final score = await TfliteService.instance.predictRaw(scaled, type);
      final percent = FeatureScaler.scoreToPercent(score);
      final label = _labelFor(percent);

      await LocalStorageService.addHistoryEntry(
        model: modelName,
        percent: percent,
        rawScore: score,
        label: label,
      );

      return ModelResultData(percent: percent, rawScore: score, label: label);
    } catch (e) {
      return ModelResultData(error: e.toString());
    }
  }

  void reset() {
    rawRiskScore = null;
    riskPercent = null;
    riskLabel = null;
    riskSummary = null;
    errorMessage = null;
    mlpResult = null;
    tabnetResult = null;
    notifyListeners();
  }
}
