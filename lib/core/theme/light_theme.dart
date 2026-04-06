import 'package:flutter/material.dart';
import 'package:stackhive/core/theme/app_colors.dart';

class LightTheme {
  static ThemeData get theme {
    return ThemeData(

      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor:  AppColors.lightBackground,
      cardColor: AppColors.lightCard,
      
      appBarTheme: AppBarTheme(
        elevation: 0,
      ),

      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),

      textTheme: TextTheme(
        bodyMedium: TextStyle(color: AppColors.lightText),
      ),

      iconTheme: IconThemeData(
        color: AppColors.lightText,
      ),   
    );
  }
}
