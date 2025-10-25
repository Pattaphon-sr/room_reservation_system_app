import 'package:flutter/material.dart';

class AppColors {
  // โทนหลัก (พื้นหลัง)
  static const Color tealDeep = Color(0xFF0F828C);
  static const Color purpleDeep = Color(0xFF320A6B);

  // สำหรับปุ่ม/ตัวหนังสือ
  static const Color white100 = Color(
    0xFFEEEEEE,
  ); // ใช้เป็นสีปุ่ม solid ดีฟอลต์
  static const Color primary = Color(0xFF1E93AB); // ใช้เป็นสีปุ่ม solid ดีฟอลต์
  static const Color onPrimary = Colors.white; // สีตัวอักษรบนปุ่มเข้ม
  static const Color outline = Color(0xFFCBD5E1); // เส้นขอบอ่อน
  static const Color disabledBg = Color(0xFFE5E7EB);
  static const Color disabledFg = Color(0xFF9CA3AF);

  // ไล่เฉดหลัก (ใช้ทำปุ่ม/พื้นหลังแบบ gradient)
  static const List<Color> primaryGradient = [tealDeep, purpleDeep];
}
