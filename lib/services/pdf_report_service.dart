import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/patient_data.dart';

/// Builds a one-page PDF summary of the assessment and hands it to the
/// OS print/share sheet via the `printing` package - no server, no file
/// storage required, works fully offline.
class PdfReportService {
  static Future<void> printSingleResult({
    required PatientData data,
    required String modelName,
    required double percent,
    required double rawScore,
    required String riskLabel,
  }) async {
    final doc = _buildDocument(
      data: data,
      rows: [PdfResultRow(modelName, percent, rawScore, riskLabel)],
    );
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  static Future<void> printComparison({
    required PatientData data,
    required List<PdfResultRow> rows,
  }) async {
    final doc = _buildDocument(data: data, rows: rows);
    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  static pw.Document _buildDocument({
    required PatientData data,
    required List<PdfResultRow> rows,
  }) {
    final doc = pw.Document();
    final now = DateTime.now();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'HeartSense AI - Assessment Summary',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generated ${now.toString().split('.').first}',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Risk Results',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1.5),
                    2: pw.FlexColumnWidth(1.5),
                    3: pw.FlexColumnWidth(2),
                  },
                  children: [
                    _tableHeaderRow(
                        ['Model', 'Risk %', 'Raw Score', 'Category']),
                    for (final r in rows)
                      _tableRow([
                        r.model,
                        '${r.percent.round()}%',
                        r.rawScore.toStringAsFixed(2),
                        r.label,
                      ]),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text('Input Data',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1.5),
                    2: pw.FlexColumnWidth(2),
                    3: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    _tableHeaderRow(['Field', 'Value', 'Field', 'Value']),
                    _tableRow([
                      'Age',
                      '${data.age.round()}',
                      'Sex',
                      data.sex == 1 ? 'Male' : 'Female',
                    ]),
                    _tableRow([
                      'Chest Pain Type',
                      OptionLabelsSafe.cp(data.cp),
                      'Resting BP',
                      '${data.restingBp.round()} mmHg',
                    ]),
                    _tableRow([
                      'Cholesterol',
                      '${data.cholesterol.round()} mg/dl',
                      'Fasting Blood Sugar >120',
                      data.highFastingBloodSugar ? 'Yes' : 'No',
                    ]),
                    _tableRow([
                      'Resting ECG',
                      OptionLabelsSafe.restEcg(data.restEcg),
                      'Max Heart Rate',
                      '${data.maxHeartRate.round()} bpm',
                    ]),
                    _tableRow([
                      'Exercise Angina',
                      data.exerciseAngina ? 'Yes' : 'No',
                      'Oldpeak',
                      data.oldpeak.toStringAsFixed(1),
                    ]),
                    _tableRow([
                      'Slope',
                      OptionLabelsSafe.slope(data.slope),
                      'Major Vessels (CA)',
                      '${data.majorVessels}',
                    ]),
                    _tableRow([
                      'Thal',
                      OptionLabelsSafe.thal(data.thal),
                      'Max HR Reserve',
                      '${data.maxHeartRateReserve.round()}',
                    ]),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  'This summary is generated by an on-device machine learning '
                  'model for educational purposes and is not a substitute for '
                  'professional medical advice or diagnosis.',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc;
  }

  static pw.TableRow _tableHeaderRow(List<String> cells) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: cells
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(c,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ))
          .toList(),
    );
  }

  static pw.TableRow _tableRow(List<String> cells) {
    return pw.TableRow(
      children: cells
          .map((c) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(c),
              ))
          .toList(),
    );
  }
}

/// One row of model results shown in the PDF table.
class PdfResultRow {
  final String model;
  final double percent;
  final double rawScore;
  final String label;
  PdfResultRow(this.model, this.percent, this.rawScore, this.label);
}

// Lightweight local copies of the option label lookups, kept private to
// this file so pdf_report_service.dart has no dependency on the UI
// constants file. Keep in sync with lib/constants/option_labels.dart if
// you add/change categories.
class OptionLabelsSafe {
  static String cp(int i) => const [
        'Typical Angina',
        'Atypical Angina',
        'Non-anginal Pain',
        'Asymptomatic',
      ][i.clamp(0, 3)];

  static String restEcg(int i) => const [
        'Normal',
        'ST-T Wave Abnormality',
        'Left Ventricular Hypertrophy',
      ][i.clamp(0, 2)];

  static String slope(int i) =>
      const ['Upsloping', 'Flat', 'Downsloping'][i.clamp(0, 2)];

  static String thal(int i) => const [
        'Category 0',
        'Category 1',
        'Category 2',
        'Category 3',
      ][i.clamp(0, 3)];
}
