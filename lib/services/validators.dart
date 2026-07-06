/// Simple range validators for the numeric input fields. Ranges are set
/// generously around what's physiologically plausible / seen in
/// heartv1.csv, just to catch typos (e.g. "1200" instead of "120") rather
/// than to be strict medical bounds.
class Validators {
  static String? restingBp(String value) {
    final v = double.tryParse(value);
    if (v == null) return 'Enter a number';
    if (v < 60 || v > 250) return 'Enter a value between 60-250 mmHg';
    return null;
  }

  static String? cholesterol(String value) {
    final v = double.tryParse(value);
    if (v == null) return 'Enter a number';
    if (v < 100 || v > 600) return 'Enter a value between 100-600 mg/dl';
    return null;
  }

  static String? maxHeartRate(String value) {
    final v = double.tryParse(value);
    if (v == null) return 'Enter a number';
    if (v < 60 || v > 220) return 'Enter a value between 60-220 bpm';
    return null;
  }

  static String? oldpeak(String value) {
    final v = double.tryParse(value);
    if (v == null) return 'Enter a number';
    if (v < 0 || v > 10) return 'Enter a value between 0-10';
    return null;
  }

  static String? maxHeartRateReserve(String value) {
    final v = double.tryParse(value);
    if (v == null) return 'Enter a number';
    if (v < -50 || v > 100) return 'Enter a value between -50 and 100';
    return null;
  }
}
