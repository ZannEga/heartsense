import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A field label with a small tappable info icon next to it - taps open a
/// plain-language explanation dialog. Used for medical-jargon terms
/// (Oldpeak, Thal, CA, etc.) that aren't self-explanatory to a lay user.
class InfoLabel extends StatelessWidget {
  final String label;
  final String info;

  const InfoLabel({super.key, required this.label, required this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(label),
              content: Text(info, style: const TextStyle(height: 1.4)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
          child: const Icon(Icons.info_outline,
              size: 16, color: AppColors.subtitleGray),
        ),
      ],
    );
  }
}
