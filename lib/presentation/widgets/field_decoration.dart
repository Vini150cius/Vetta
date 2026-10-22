import 'package:flutter/material.dart';

InputDecoration fieldDecoration(String label, {IconData? icon, String? hint}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      border: const OutlineInputBorder(),
    );
