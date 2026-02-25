import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.cream,
    primaryColor: AppColors.saffron,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.saffron,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.deepBrown,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.deepBrown,
      ),
    ),

    useMaterial3: true,
  );
}