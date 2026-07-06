/// Shared label lists for the dropdown fields, kept in one place so the
/// input screens and the Review screen always show identical text for
/// the same underlying code.
class OptionLabels {
  static const cp = [
    'Typical Angina',
    'Atypical Angina',
    'Non-anginal Pain',
    'Asymptomatic',
  ];

  static const restEcg = [
    'Normal',
    'ST-T Wave Abnormality',
    'Left Ventricular Hypertrophy',
  ];

  static const slope = ['Upsloping', 'Flat', 'Downsloping'];

  // 'ca' has 5 categories in heartv1.csv (0-4), not the standard UCI 0-3.
  static const vessels = ['0', '1', '2', '3', '4'];

  // 'thal' has 4 categories in heartv1.csv (0-3). The dataset doesn't
  // document what each code means, so plain category labels are used
  // instead of guessing clinical names.
  static const thal = ['Category 0', 'Category 1', 'Category 2', 'Category 3'];
}
