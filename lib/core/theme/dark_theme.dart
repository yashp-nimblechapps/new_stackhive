import 'package:flutter/material.dart';
import 'package:stackhive/core/theme/app_colors.dart';

class DarkTheme {

  static ThemeData get theme {
    return ThemeData(

      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,

      appBarTheme: AppBarTheme(
        elevation: 0,
      ),

      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),

      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: AppColors.darkText,
        ),
      ),

      iconTheme: IconThemeData(
        color: AppColors.darkText,
      ),
    );
  }
  
}