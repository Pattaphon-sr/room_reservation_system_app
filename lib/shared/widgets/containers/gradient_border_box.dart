import 'package:flutter/material.dart';

class GradientBorderBox extends StatelessWidget {
  const GradientBorderBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.borderWidth = 2,
    required this.borderGradient,
    this.backgroundColor = Colors.transparent,
    // Shadow (outside-only, gradient)
    this.shadowGradient,
    this.shadowBlurSigma = 16,
    this.shadowOffset = const Offset(0, 8),
    this.shadowSpread = 8,
    this.child,
  });

  final double? width;
  final double? height;

  // Border
  final double borderRadius;
  final double borderWidth;
  final Gradient borderGradient;

  // Fill
  final Color backgroundColor;

  // Shadow (gradient outside only)
  final Gradient? shadowGradient;
  final double shadowBlurSigma;
  final Offset shadowOffset;
  final double shadowSpread;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientBorderShadowPainter(
        borderRadius: borderRadius,
        borderWidth: borderWidth,
        borderGradient: borderGradient,
        shadowGradient: shadowGradient,
        shadowBlurSigma: shadowBlurSigma,
        shadowOffset: shadowOffset,
        shadowSpread: shadowSpread,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          height: height,
          color: backgroundColor,
          child: child,
        ),
      ),
    );
  }
}

class _GradientBorderShadowPainter extends CustomPainter {
  _GradientBorderShadowPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.borderGradient,
    required this.shadowGradient,
    required this.shadowBlurSigma,
    required this.shadowOffset,
    required this.shadowSpread,
  });

  final double borderRadius;
  final double borderWidth;
  final Gradient borderGradient;

  final Gradient? shadowGradient;
  final double shadowBlurSigma;
  final Offset shadowOffset;
  final double shadowSpread;

  @override
  void paint(Canvas canvas, Size size) {
    final baseRect = Offset.zero & size;

    // ===== 1) เงาแบบ Gradient "นอกกล่องเท่านั้น" =====
    if (shadowGradient != null && shadowBlurSigma > 0) {
      // สร้างกรอบด้านใน (ตัวกล่องจริง)
      final innerRRect = RRect.fromRectAndRadius(
        baseRect,
        Radius.circular(borderRadius),
      );

      // สร้างกรอบด้านนอก (ขยาย + เลื่อนตาม offset)
      final outerRect = Rect.fromLTWH(
        shadowOffset.dx,
        shadowOffset.dy,
        size.width,
        size.height,
      ).inflate(shadowSpread);

      final outerRRect = RRect.fromRectAndRadius(
        outerRect,
        Radius.circular(borderRadius + shadowSpread),
      );

      // วาดเฉพาะวงแหวน "ภายนอก" = outer - inner
      final outerPath = Path()..addRRect(outerRRect);
      final innerPath = Path()..addRRect(innerRRect);
      final ringPath = Path.combine(
        PathOperation.difference,
        outerPath,
        innerPath,
      );

      final shadowPaint = Paint()
        ..shader = shadowGradient!.createShader(outerRect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlurSigma)
        ..style = PaintingStyle.fill;

      canvas.drawPath(ringPath, shadowPaint);
    }

    // ===== 2) เส้นขอบแบบ Gradient =====
    final borderRect = baseRect.deflate(borderWidth / 2);
    final borderRRect = RRect.fromRectAndRadius(
      borderRect,
      Radius.circular(borderRadius - borderWidth / 2),
    );

    final borderPaint = Paint()
      ..shader = borderGradient.createShader(baseRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(borderRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderShadowPainter old) {
    return old.borderRadius != borderRadius ||
        old.borderWidth != borderWidth ||
        old.borderGradient != borderGradient ||
        old.shadowGradient != shadowGradient ||
        old.shadowBlurSigma != shadowBlurSigma ||
        old.shadowOffset != shadowOffset ||
        old.shadowSpread != shadowSpread;
  }
}
