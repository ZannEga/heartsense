import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_data.dart';

/// Persists the user's last-entered clinical data locally on the device
/// using SharedPreferences - a simple key-value file store built into
/// Android/iOS (wraps SharedPreferences on Android, NSUserDefaults on
/// iOS). This is NOT a database: no server, no schema, no query engine,
/// just a small JSON blob saved to a local file. It's what lets the app
/// "remember" previous inputs the next time it's opened, without
/// violating the no-backend/no-database requirement.
class LocalStorageService {
  static const _key = 'heartsense_patient_data';
  static const _historyKey = 'heartsense_history';
  static const _maxHistoryEntries = 50;

  static Future<void> savePatientData(PatientData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toMap()));
  }

  static Future<PatientData?> loadPatientData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PatientData.fromMap(map);
    } catch (_) {
      // Corrupted or old-format data (e.g. from a previous app version
      // with different fields) - ignore it and start fresh rather than
      // crash the app.
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // --- Assessment history -------------------------------------------------
  // Stored as a list of small JSON strings (newest first), capped at
  // [_maxHistoryEntries] so storage doesn't grow unbounded.

  static Future<void> addHistoryEntry({
    required String model,
    required double percent,
    required double rawScore,
    required String label,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_historyKey) ?? [];
    final entry = jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'model': model,
      'percent': percent,
      'rawScore': rawScore,
      'label': label,
    });
    existing.insert(0, entry);
    if (existing.length > _maxHistoryEntries) {
      existing.removeRange(_maxHistoryEntries, existing.length);
    }
    await prefs.setStringList(_historyKey, existing);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw
        .map((s) {
          try {
            return jsonDecode(s) as Map<String, dynamic>;
          } catch (_) {
            return null;
          }
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
