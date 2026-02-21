import 'package:flutter/material.dart';

ColorScheme colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xff1c58b6),
  brightness: Brightness.light,

  // Primary (Blue) - used for main actions, headers, etc.
  primary: const Color(0xff1c58b6),
  onPrimary: const Color(0xff000000),

  // Primary Container (Light Blue) - used for info boxes
  primaryContainer: const Color(0xFFE3F2FD), // Blue 50
  onPrimaryContainer: const Color(0xFF1565C0), // Blue 800

  // Secondary (Greyish Pink/Purple from original design) - used for "other" chat bubbles
  secondary: const Color(0xd3aba5a5),
  onSecondary: const Color(0xff000000),

  // Tertiary (Green) - used for Success states
  tertiary: const Color(0xFF4CAF50), // Green
  onTertiary: const Color(0xffffffff),
  tertiaryContainer: const Color(0xFFE8F5E9), // Green 50
  onTertiaryContainer: const Color(0xFF2E7D32), // Green 800

  // Error (Red)
  error: const Color(0xff710404),
  errorContainer: const Color(0xFFFFEBEE), // Red 50
  onError: const Color(0xffffffff),

  // Surface & Greys
  surface: const Color(0xffffffff),
  onSurface: const Color(0xff000000),

  // Mapping specific grey shades to standard roles
  surfaceContainerHighest: const Color(0xFFF5F5F5), // Grey 100 - Input background
  outline: const Color(0xFFE0E0E0), // Grey 300 - Borders
  outlineVariant: const Color(0xFFEEEEEE), // Grey 200 - Dividers
  onSurfaceVariant: const Color(0xFF757575), // Grey 600 - Secondary text
);
