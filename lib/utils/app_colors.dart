import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4C4DDC);
  static const Color primaryLight = Color(0xFFEFEFFD);
  static const Color primaryDark = Color(0xFF2B2A9B);
  
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  
  static const Color accentBlue = Color(0xFF38BDF8);
  static const Color accentOrange = Color(0xFFFF7A00);
  
  static const Color cardShadow = Color(0x0F000000);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputBackground = Color(0xFFF8FAFC);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4C4DDC),
      Color(0xFF6B6CFF),
    ],
  );
}
