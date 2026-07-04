import 'package:tflite_flutter/tflite_flutter.dart';

enum MlModelType { mlp, tabnet }

/// Loads and runs the on-device .tflite model(s), both from
/// UAS_MLPrak-main (mlp.keras converted to mlp_model.tflite, and TabNet
/// converted via tools/convert_tabnet_to_tflite.py):
///   input  shape [1, 14] float32
///   output shape [1, 1]  float32 (single linear/regression neuron)
///
/// Both are REGRESSION models predicting a continuous "Heart Disease Risk
/// Score" directly (their target wasn't scaled during training), so the
/// raw output is already in real units - no inverse-transform needed.
class TfliteService {
  TfliteService._internal();
  static final TfliteService instance = TfliteService._internal();

  Interpreter? _mlpInterpreter;
  Interpreter? _tabnetInterpreter;

  Future<void> loadModels() async {
    _mlpInterpreter ??=
        await Interpreter.fromAsset('assets/models/mlp_model.tflite');

    // Load TabNet once you've run tools/convert_tabnet_to_tflite.py and
    // placed the result at assets/models/tabnet_model.tflite. Loading is
    // wrapped in a try/catch so the MLP path keeps working even if the
    // TabNet file isn't there yet.
    try {
      _tabnetInterpreter ??=
          await Interpreter.fromAsset('assets/models/tabnet_model.tflite');
    } catch (_) {
      // Left null - AssessmentProvider surfaces a friendly error if the
      // user picks TabNet before the file has been added.
    }
  }

  /// Runs inference and returns the RAW model output - already the actual
  /// "Heart Disease Risk Score" for both models (see class doc above).
  Future<double> predictRaw(List<double> scaledFeatures, MlModelType type) async {
    final interpreter =
        type == MlModelType.mlp ? _mlpInterpreter : _tabnetInterpreter;
    if (interpreter == null) {
      throw StateError(
        type == MlModelType.mlp
            ? 'MLP model not loaded. Call loadModels() first.'
            : 'TabNet model not found - run tools/convert_tabnet_to_tflite.py '
                'and place tabnet_model.tflite in assets/models/.',
      );
    }

    final input = [scaledFeatures]; // shape: [1, 14]
    final output = [List.filled(1, 0.0)]; // shape: [1, 1]
    interpreter.run(input, output);
    return output[0][0];
  }

  void close() {
    _mlpInterpreter?.close();
    _tabnetInterpreter?.close();
    _mlpInterpreter = null;
    _tabnetInterpreter = null;
  }
}
