import 'package:flutter/material.dart';

class AppColors {
  // โทนหลัก (พื้นหลัง)
  static const Color mintSoft = Color(0xFF78B9B5);
  static const Color tealSoft = Color(0xFF78B9B5);
  static const Color tealPrimary = Color(0xFF0F828C);
  static const Color oceanDeep = Color(0xFF065084);
  static const Color purpleDeep = Color(0xFF320A6B);

  // room status
  static const Color roomBlue = Color(0xFF0F828C);
  static const Color roomGrey = Color(0xFF848484);
  static const Color roomdecoration = Color(0xFFEFF5D2);

  // Pink / Rose
  static const Color roseMist = Color(0xFFF5D2D2);
  static const Color roseSoft = Color(0xFFFFBFBF);
  static const Color roseBright = Color(0xFFFFA9A9);

  // Violet / Purple
  static const Color lavenderGlow = Color(0xFFBF8DFF);
  static const Color iris = Color(0xFFAF73FF);
  static const Color grapeDark = Color(0xFF63458D);

  // สำหรับปุ่ม/ตัวหนังสือ
  static const Color white100 = Color(0xFFEEEEEE);

  // ใช้เป็นสีปุ่ม solid ดีฟอลต์
  static const Color primary = Color(0xFF1E93AB);
  static const Color onPrimary = Colors.white;
  static const Color outline = Color(0xFFCBD5E1);

  // Status
  static const Color warning = Color(0xFFFF9D23);
  static const Color danger = Color(0xFFE62727);
  static const Color success = Color(0xFF399918);

  // ไล่เฉดหลัก (gradient)
  static const List<Color> primaryGradient2C = [tealPrimary, purpleDeep];
  static const List<Color> primaryGradient5C = [
    AppColors.purpleDeep,
    AppColors.oceanDeep,
    AppColors.tealPrimary,
    AppColors.mintSoft,
    Colors.white,
  ];
}

class AppColorStops {
  static const List<double> primaryStop5C = [0.0, 0.25, 0.4, 0.50, 0.75];
}
