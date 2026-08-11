import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D6B), // calm teal — health/wellness tone
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
      );
}
