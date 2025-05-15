import 'package:flutter/material.dart';

// Shadcn-inspired dark theme
final ThemeData shadcnDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: const Color(0xFF09090B),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF3B82F6),      // blue-500
    onPrimary: Colors.white,
    secondary: Color(0xFFF97316),    // orange-500
    onSecondary: Colors.black,
    background: Color(0xFF09090B),
    onBackground: Colors.white,
    surface: Color(0xFF18181B),
    onSurface: Colors.white,
    error: Color(0xFFEF4444),
    onError: Colors.white,
  ),
  cardColor: const Color(0xFF18181B),
  dividerColor: const Color(0xFF27272A),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF18181B),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF27272A)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
    ),
    labelStyle: const TextStyle(color: Color(0xFFA1A1AA)), // muted text
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
    titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA1A1AA)),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.25, color: Colors.white),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: const Color(0xFF18181B),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
    contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFA1A1AA)),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF1F2937),
    contentTextStyle: const TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);

// Shadcn-inspired light theme
final ThemeData shadcnLightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: Colors.white,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF1D4ED8),      // blue-700
    onPrimary: Colors.white,
    secondary: Color(0xFFEA580C),    // orange-600
    onSecondary: Colors.white,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Color(0xFFF9FAFB),
    onSurface: Colors.black,
    error: Color(0xFFB91C1C),
    onError: Colors.white,
  ),
  cardColor: const Color(0xFFF9FAFB),
  dividerColor: const Color(0xFFE4E4E7),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF4F4F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE4E4E7)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 2),
    ),
    labelStyle: const TextStyle(color: Color(0xFF52525B)), // muted text
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black),
    titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF52525B)),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.25, color: Colors.black),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
    contentTextStyle: const TextStyle(fontSize: 16, color: Colors.black),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF52525B)),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFFF3F4F6),
    contentTextStyle: const TextStyle(color: Colors.black),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);
