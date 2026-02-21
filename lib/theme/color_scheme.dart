import 'package:flutter/material.dart';

ColorScheme colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xff1c58b6),
  brightness: Brightness.light,
  surface: const Color(0xffffffff),
  primary: const Color(0xff1c58b6),
  error: const Color(0xff710404),
  secondary: const Color(0xd3aba5a5),
  onPrimary: const Color(0xff000000),
  onSurface: const Color(0xff000000),
);

// Extended colors to match the specific shades used in the app
// Ideally these would be part of a custom theme extension, but for this refactor
// we will expose them statically or via the color scheme where possible.
// We are mapping existing usage to these or standard ColorScheme fields.

extension CustomColors on ColorScheme {
  Color get success => const Color(0xFF4CAF50); // Colors.green
  Color get warning => const Color(0xFFFFA000); // Colors.amber/orange
  Color get info => const Color(0xFF2196F3); // Colors.blue

  Color get grey => const Color(0xFF9E9E9E); // Colors.grey
  Color get grey50 => const Color(0xFFFAFAFA);
  Color get grey100 => const Color(0xFFF5F5F5);
  Color get grey200 => const Color(0xFFEEEEEE);
  Color get grey300 => const Color(0xFFE0E0E0);
  Color get grey400 => const Color(0xFFBDBDBD);
  Color get grey500 => const Color(0xFF9E9E9E);
  Color get grey600 => const Color(0xFF757575);
  Color get grey700 => const Color(0xFF616161);
  Color get grey800 => const Color(0xFF424242);
}
