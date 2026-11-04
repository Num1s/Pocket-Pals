import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'sans-serif',
    scaffoldBackgroundColor: AppColors.background,
  );
}
