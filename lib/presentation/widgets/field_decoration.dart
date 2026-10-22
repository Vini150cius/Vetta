import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

InputDecoration fieldDecoration(String label, {IconData? icon, String? hint}) {
  OutlineInputBorder border(Color color, [double width = 0]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: width == 0
            ? BorderSide.none
            : BorderSide(color: color, width: width),
      );
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon),
    filled: true,
    border: border(Colors.transparent),
    enabledBorder: border(Colors.transparent),
    focusedBorder: border(AppTheme.primary, 1.8),
    errorBorder: border(AppTheme.expenseColor, 1.4),
    focusedErrorBorder: border(AppTheme.expenseColor, 1.8),
  );
}
