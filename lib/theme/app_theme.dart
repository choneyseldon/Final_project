import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF8B7FD8); // Purple color from the design
  static const Color primaryLightColor = Color(0xFFA298E0);
  static const Color primaryDarkColor = Color(0xFF6B5FBF);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF2D3748);
  static const Color textSecondaryColor = Color(0xFF718096);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(
        primaryColor.value,
        <int, Color>{
          50: primaryColor.withOpacity(0.1),
          100: primaryColor.withOpacity(0.2),
          200: primaryColor.withOpacity(0.3),
          300: primaryColor.withOpacity(0.4),
          400: primaryColor.withOpacity(0.5),
          500: primaryColor,
          600: primaryColor.withOpacity(0.7),
          700: primaryColor.withOpacity(0.8),
          800: primaryColor.withOpacity(0.9),
          900: primaryColor,
        },
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      fontFamily: 'Nunito', // Set Nunito as default font
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, fontSize: 57, color: textColor),
        displayMedium: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, fontSize: 45, color: textColor),
        displaySmall: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, fontSize: 36, color: textColor),
        headlineLarge: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, fontSize: 32, color: textColor),
        headlineMedium: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, fontSize: 28, color: textColor),
        headlineSmall: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.w600, fontSize: 24, color: textColor),
        titleLarge: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.w600, fontSize: 22, color: textColor),
        titleMedium: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 16, color: textColor),
        titleSmall: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
        bodyLarge: TextStyle(fontFamily: 'Nunito', fontSize: 16, color: textColor),
        bodyMedium: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: textColor),
        bodySmall: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: textSecondaryColor),
        labelLarge: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
        labelMedium: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: textColor),
        labelSmall: TextStyle(fontFamily: 'Nunito', fontSize: 11, color: textSecondaryColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Raleway',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(
          fontFamily: 'Nunito',
          color: textSecondaryColor,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Nunito',
          color: textSecondaryColor,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}