import 'package:flutter/material.dart';
import '../../../../core/constants/design_constants.dart';

/// Виджет для ввода текста
class TextInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool enabled;

  const TextInputWidget({
    super.key,
    required this.controller,
    required this.hint,
    required this.label,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignConstants.borderRadius),
        ),
        contentPadding: const EdgeInsets.all(DesignConstants.padding),
      ),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }
} 