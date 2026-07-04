/// Raw clinical data collected from the user across the input screens.
///
/// Both models (MLP and TabNet) come from UAS_MLPrak-main and share the
/// EXACT SAME preprocessing pipeline (`src/preprocessing.py`), the same
/// `models/scaler.pkl`, and the same `models/feature_columns.pkl` - so a
/// single feature vector / scaler works for both. Order verified against
/// `feature_columns.pkl`:
///
///   sex, age, cp, resting_BP, chol, fbs, restecg, thalach, exang,
///   oldpeak, slope, ca, thal, Max Heart Rate Reserve
///
/// Note: `target` (existing diagnosis) is NOT a feature for either model -
/// `config.py`'s DROP_COLUMNS explicitly removes it before training.
class PatientData {
  // sex: LabelEncoder was alphabetical -> female = 0, male = 1
  int sex = 1;
  double age = 45;

  int cp = 0; // chest pain type: 0-3
  double restingBp = 120; // resting_BP

  double cholesterol = 200; // chol
  bool highFastingBloodSugar = false; // fbs: fasting blood sugar > 120 mg/dl
  int restEcg = 0; // 0-2

  double maxHeartRate = 150; // thalach
  bool exerciseAngina = false; // exang
  double oldpeak = 1.0;
  int slope = 0; // 0-2
  int majorVessels = 0; // ca: 0-4 (5 categories in this dataset)
  int thal = 0; // 0-3 (4 categories in this dataset)

  /// Not derivable from age/thalach with a clean formula (checked against
  /// the real data) - collected as its own input. Observed training range
  /// roughly -29 to 82.
  double maxHeartRateReserve = 15;

  /// Exact order required by both mlp_model.tflite and tabnet_model.tflite
  /// (14 features).
  List<double> toFeatureVector() {
    return [
      sex.toDouble(),
      age,
      cp.toDouble(),
      restingBp,
      cholesterol,
      highFastingBloodSugar ? 1.0 : 0.0,
      restEcg.toDouble(),
      maxHeartRate,
      exerciseAngina ? 1.0 : 0.0,
      oldpeak,
      slope.toDouble(),
      majorVessels.toDouble(),
      thal.toDouble(),
      maxHeartRateReserve,
    ];
  }
}
