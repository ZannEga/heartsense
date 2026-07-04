/// Replicates the single shared StandardScaler from UAS_MLPrak-main
/// (`models/scaler.pkl`), fit on the training split only (218 of 312 rows),
/// used identically by both mlp.keras and the TabNet model - confirmed by
/// loading scaler.pkl directly and reading `.mean_` / `.scale_`.
///
/// Order matches PatientData.toFeatureVector():
/// sex, age, cp, resting_BP, chol, fbs, restecg, thalach, exang, oldpeak,
/// slope, ca, thal, Max Heart Rate Reserve
///
/// Neither model scales the target ("Heart Disease Risk Score") - both
/// were trained against raw y values, so the model's raw output is
/// already in real risk-score units. No inverse-transform is needed for
/// either model's output.
class FeatureScaler {
  static const List<double> mean = [
    0.6788990825688074, // sex
    56.45871559633027, // age
    0.9220183486238532, // cp
    130.73853211009174, // resting_BP
    246.72935779816513, // chol
    0.14678899082568808, // fbs
    0.5091743119266054, // restecg
    149.19724770642202, // thalach
    0.3302752293577982, // exang
    1.0967889908256878, // oldpeak
    1.371559633027523, // slope
    0.7844036697247706, // ca
    2.334862385321101, // thal
    16.270642201834864, // Max Heart Rate Reserve
  ];

  static const List<double> scale = [
    0.466899473394476,
    8.821400282124328,
    1.0397474815316465,
    17.232369840575135,
    53.70754274116438,
    0.35389544077038365,
    0.5179425217665415,
    23.571336031993113,
    0.4703121327697723,
    1.169622679480807,
    0.6240724115711807,
    1.0156278224566324,
    0.6002868040505688,
    21.493228303126756,
  ];

  // Observed min/max of the ACTUAL Heart Disease Risk Score across the
  // full 312-row deduplicated heartv1.csv. Used only to turn the model's
  // raw output into a 0-100% gauge for the UI - a display choice, not
  // something either model outputs directly.
  static const double observedMin = 7.54;
  static const double observedMax = 18.8;

  static List<double> standardize(List<double> raw) {
    assert(raw.length == mean.length, 'Feature vector length mismatch');
    return List<double>.generate(
      raw.length,
      (i) => (raw[i] - mean[i]) / scale[i],
    );
  }

  /// Maps the raw risk score onto a 0-100% scale for the results gauge,
  /// clamped to the range actually observed in the training data.
  static double scoreToPercent(double rawScore) {
    final clamped = rawScore.clamp(observedMin, observedMax);
    return ((clamped - observedMin) / (observedMax - observedMin)) * 100;
  }
}
