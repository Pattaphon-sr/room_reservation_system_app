import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';

enum AppButtonVariant { solid, outline }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  // ขนาด/มุม
  final bool fullWidth; // true = กว้างเต็มแถว
  final double? width; // ใช้เมื่อ fullWidth = false (ดีฟอลต์ 320)
  final double height; // ดีฟอลต์ 46 (ตามตัวอย่าง)

  // สี/สไตล์
  final Color? backgroundColor; // solid
  final Color? foregroundColor; // solid/outline
  final Color? outlineColor; // outline
  final TextStyle? textStyle; // override ได้

  final AppButtonVariant variant;

  const AppButton.solid({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false, // ค่าเริ่มต้นให้เหมือน Size(320,46)
    this.width,
    this.height = 46,
    this.backgroundColor, // ถ้าไม่ส่ง = AppColors.buttonPrimary
    this.foregroundColor, // ถ้าไม่ส่ง = AppColors.onButtonPrimary
    this.textStyle, // ถ้าไม่ส่ง = TextStyle(fontSize:18, fontWeight:w700)
  }) : variant = AppButtonVariant.solid,
       outlineColor = null;

  const AppButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
    this.width,
    this.height = 46,
    this.outlineColor, // ถ้าไม่ส่ง = AppColors.buttonPrimary
    this.foregroundColor, // ถ้าไม่ส่ง = AppColors.buttonPrimary
    this.textStyle,
  }) : variant = AppButtonVariant.outline,
       backgroundColor = null;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.solid:
        return _buildSolid(context);
      case AppButtonVariant.outline:
        return _buildOutline(context);
    }
  }

  // เนื้อหา (เฉพาะข้อความ)
  Widget _content(Color fg) {
    final style =
        textStyle ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : (width ?? 320),
      child: Center(
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(color: fg),
        ),
      ),
    );
  }

  // แบบ SOLID (ElevatedButton)
  Widget _buildSolid(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary;
    final fg = foregroundColor ?? AppColors.onPrimary;

    return SizedBox(
      width: fullWidth ? double.infinity : (width ?? 320),
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          textStyle:
              (textStyle ??
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          // ให้ขนาดตามดีฟอลต์ตัวอย่าง
          fixedSize: Size(fullWidth ? double.infinity : (width ?? 320), height),
          padding: EdgeInsets.zero,
        ),
        child: _content(fg),
      ),
    );
  }

  // แบบ OUTLINE (OutlinedButton)
  Widget _buildOutline(BuildContext context) {
    final oc = outlineColor ?? AppColors.onPrimary;
    final fg = foregroundColor ?? AppColors.onPrimary;

    return SizedBox(
      width: fullWidth ? double.infinity : (width ?? 320),
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: oc, width: 1.2),
          textStyle:
              (textStyle ??
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          fixedSize: Size(fullWidth ? double.infinity : (width ?? 320), height),
          padding: EdgeInsets.zero,
        ),
        child: _content(fg),
      ),
    );
  }
}
