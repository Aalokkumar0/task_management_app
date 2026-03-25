import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _seed = Color.fromARGB(128, 0, 4, 255); // Modern Indigo (slightly vibrant)

  // Status colours (more vibrant)
  static const colorTodo = Color(0xFF94A3B8);
  static const colorInProgress = Color(0xFFF59E0B);
  static const colorDone = Color(0xFF22C55E);
  static const colorBlocked = Color(0xFFEF4444);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seed,
        brightness: Brightness.light,

        // 🌈 Background
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),

        // 🔤 Typography
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 14),
        ),

        // 📱 AppBar (glass + modern)
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Color.fromARGB(181, 92, 46, 46),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        // 🧾 Cards (soft UI)
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // ✏️ Input fields (clean + modern)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 75, 60, 60),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _seed, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),

        // 🔘 Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _seed,
            foregroundColor: const Color.fromARGB(255, 113, 87, 87),
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        // 🟣 Floating Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          foregroundColor: Color.fromARGB(255, 171, 155, 155),
          elevation: 6,
        ),

        // 🏷 Chips
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: _seed.withValues(alpha: 0.1),
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),

        // 📏 Divider
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade200,
          thickness: 1,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seed,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      );

  // 🎯 Status Color
  static Color statusColor(String statusLabel) {
    switch (statusLabel) {
      case 'To-Do':
        return colorTodo;
      case 'In Progress':
        return colorInProgress;
      case 'Done':
        return colorDone;
      case 'Blocked':
        return colorBlocked;
      default:
        return colorTodo;
    }
  }

  // 🎯 Status Icon
  static IconData statusIcon(String statusLabel) {
    switch (statusLabel) {
      case 'To-Do':
        return Icons.radio_button_unchecked_rounded;
      case 'In Progress':
        return Icons.timelapse_rounded;
      case 'Done':
        return Icons.check_circle_rounded;
      case 'Blocked':
        return Icons.block_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }
}