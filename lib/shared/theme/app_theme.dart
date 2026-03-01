import 'package:flutter/material.dart';

class AppTheme {
  // FINLUX Inspired Palette
  static const Color primaryLight = Color(0xFF00B8D4);
  static const Color backgroundLight = Color(0xFFF6F8FA);
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF1F2328);
  static const Color textSecondaryLight = Color(0xFF656D76);
  static const Color borderLight = Color(0xFFD0D7DE);

  static const Color primaryDark = Color(0xFF00E5FF); // Neon Cyan
  static const Color backgroundDark = Color(0xFF010409); // Deep Black
  static const Color cardDark = Color(0xFF0D1117); // Dark Grey
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color borderDark = Color(0xFF30363D);

  static const Color incomeColor = Color(0xFF00E676);
  static const Color expenseColor = Color(0xFFFF5252);

  static const double borderRadius = 16.0; // Reduced from the "round round" design

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    primaryColor: primaryLight,
    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      secondary: primaryLight,
      surface: cardLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
      error: expenseColor,
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: const BorderSide(color: borderLight, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(color: borderLight),
    iconTheme: const IconThemeData(color: primaryLight),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimaryLight, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondaryLight, fontSize: 14),
      headlineSmall: TextStyle(color: textPrimaryLight, fontWeight: FontWeight.bold),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimaryLight),
      titleTextStyle: TextStyle(color: textPrimaryLight, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        elevation: 0,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryDark,
    canvasColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: primaryDark,
      surface: cardDark,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: textPrimaryDark,
      error: expenseColor,
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: const BorderSide(color: borderDark, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(color: borderDark),
    iconTheme: const IconThemeData(color: primaryDark),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimaryDark, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondaryDark, fontSize: 14),
      headlineSmall: TextStyle(color: textPrimaryDark, fontWeight: FontWeight.bold),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimaryDark),
      titleTextStyle: TextStyle(color: textPrimaryDark, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        elevation: 0,
      ),
    ),
  );
}
