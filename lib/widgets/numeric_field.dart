import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NumericField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;
  final String? errorText;

  const NumericField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFFF5F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.riskOrange),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
