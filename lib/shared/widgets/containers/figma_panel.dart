import 'dart:ui';
import 'package:flutter/material.dart';

/// ตำแหน่งของ Stroke (เหมือน Figma)
enum StrokePosition { inside, center, outside }

/// สเปกเส้นขอบ (Stroke) — รองรับ Gradient + ตำแหน่ง + ความหนา
class StrokeSpec {
  final Gradient gradient;
  final double weight;
  final StrokePosition position;
  const StrokeSpec({
    required this.gradient,
    this.weight = 1.0,
    this.position = StrokePosition.center,
  });
}

/// สเปกเงา (Drop shadow) — outside only, รองรับ Gradient/Color
class ShadowSpec {
  /// เลือก color หรือ gradient (gradient จะถูกใช้เป็นหลักถ้ากำหนด)
  final Color? color;
  final Gradient? gradient;

  /// ตำแหน่งเงา
  final double offsetX;
  final double offsetY;

  /// ความเบลอ (sigma)
  final double blurSigma;

  /// ขยาย/หดวงเงา (ติดลบได้)
  final double spread;

  const ShadowSpec({
    this.color,
    this.gradient,
    this.offsetX = 0,
    this.offsetY = 4,
    this.blurSigma = 24,
    this.spread = -1,
  });
}

/// Fill แต่ละชั้น (สี/กราเดียนต์ + ความทึบ + จะทับบน child ไหม)
class FillLayer {
  final Color? color;
  final Gradient? gradient;
  final double opacity; // 0..1
  final bool onTopOfChild; // true = วางเหนือ child

  const FillLayer.color(
    this.color, {
    this.opacity = 1.0,
    this.onTopOfChild = false,
  }) : gradient = null;

  const FillLayer.gradient(
    this.gradient, {
    this.opacity = 1.0,
    this.onTopOfChild = false,
  }) : color = null;
}

/// แผงแบบ Figma: Stroke ไล่สี (inside/center/outside) + เงา gradient (outside-only)
/// + Fill หลายเลเยอร์ + Background blur (เฉพาะภายใน)
class FigmaPanel extends StatelessWidget {
  const FigmaPanel({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 24,
    this.stroke,
    this.shadow,
    this.backgroundBlurSigma = 0,
    this.fills = const <FillLayer>[],
    this.child,
  });

  final double? width;
  final double? height;

  /// มุมโค้ง
  final double borderRadius;

  /// เส้นขอบ (ถ้าไม่กำหนด = ไม่มี)
  final StrokeSpec? stroke;

  /// เงาดรอป (ถ้าไม่กำหนด = ไม่มี)
  final ShadowSpec? shadow;

  /// เบลอพื้นหลัง “ภายในกรอบ” (BackdropFilter)
  final double backgroundBlurSigma;

  /// Fill หลายชั้น (สี/gradient) + opacity + วางบน/ใต้ child
  final List<FillLayer> fills;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // วางเป็น 3 ชั้น: Shadow (ล่าง) → Content+Blur+Fills (กลาง) → Stroke (บน)
    return Stack(
      children: [
        // 1) เงา (outside only)
        CustomPaint(
          painter: _ShadowPainter(radius: borderRadius, shadow: shadow),
          child: SizedBox(width: width, height: height),
        ),

        // 2) เนื้อหาภายใน + เบลอ + ฟิลล์
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                if (backgroundBlurSigma > 0)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: backgroundBlurSigma,
                        sigmaY: backgroundBlurSigma,
                      ),
                      child: const SizedBox.shrink(),
                    ),
                  ),

                // fills ใต้ child
                for (final f in fills.where((f) => !f.onTopOfChild))
                  Positioned.fill(child: _buildFill(f)),

                if (child != null) Positioned.fill(child: child!),

                // fills เหนือ child
                for (final f in fills.where((f) => f.onTopOfChild))
                  Positioned.fill(child: _buildFill(f)),
              ],
            ),
          ),
        ),

        // 3) เส้นขอบ (อยู่บนสุด ไม่โดนเบลอ)
        CustomPaint(
          foregroundPainter: _StrokePainter(
            radius: borderRadius,
            stroke: stroke,
          ),
          child: SizedBox(width: width, height: height),
        ),
      ],
    );
  }

  Widget _buildFill(FillLayer f) {
    final op = f.opacity.clamp(0.0, 1.0);
    if (f.gradient != null) {
      return DecoratedBox(
        decoration: BoxDecoration(gradient: f.gradient!.scale(op)),
      );
    }
    return ColoredBox(color: (f.color ?? Colors.transparent).withOpacity(op));
  }
}

/// ======================= PAINTERS =======================

class _ShadowPainter extends CustomPainter {
  _ShadowPainter({required this.radius, required this.shadow});
  final double radius;
  final ShadowSpec? shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final s = shadow;
    if (s == null ||
        (s.color == null && s.gradient == null) ||
        s.blurSigma <= 0)
      return;

    final baseRect = Offset.zero & size;

    // รูปร่างกล่องจริง (ด้านใน)
    final innerRRect = RRect.fromRectAndRadius(
      baseRect,
      Radius.circular(radius),
    );

    // สร้างกรอบนอก: เลื่อน + spread
    final movedRect = baseRect.shift(Offset(s.offsetX, s.offsetY));
    final outerRect = movedRect.inflate(s.spread);
    final outerRRect = RRect.fromRectAndRadius(
      outerRect,
      Radius.circular(radius + s.spread),
    );

    // เงาเฉพาะนอกกรอบ: outer - inner
    final outerPath = Path()..addRRect(outerRRect);
    final innerPath = Path()..addRRect(innerRRect);
    final ringPath = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma);

    if (s.gradient != null) {
      paint.shader = s.gradient!.createShader(outerRect);
    } else if (s.color != null) {
      paint.color = s.color!;
    }

    canvas.drawPath(ringPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ShadowPainter old) =>
      old.radius != radius || old.shadow != shadow;
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({required this.radius, required this.stroke});
  final double radius;
  final StrokeSpec? stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final st = stroke;
    if (st == null || st.weight <= 0) return;

    final rect = Offset.zero & size;

    // คำนวณตำแหน่งสโตรก: inside / center / outside
    double deflate;
    switch (st.position) {
      case StrokePosition.center:
        deflate = st.weight / 2;
        break;
      case StrokePosition.inside:
        deflate = st.weight;
        break;
      case StrokePosition.outside:
        deflate = 0;
        break;
    }

    // outside: ให้ดู “ขยายออก” โดยเลื่อน path ออกครึ่งหนึ่ง
    final baseRect = (st.position == StrokePosition.outside)
        ? rect.deflate(st.weight / 2)
        : rect.deflate(deflate);

    final rrect = RRect.fromRectAndRadius(
      baseRect,
      Radius.circular(
        (st.position == StrokePosition.outside)
            ? (radius + st.weight / 2)
            : (radius - deflate).clamp(0, radius),
      ),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = st.weight
      ..shader = st.gradient.createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter old) =>
      old.radius != radius || old.stroke != stroke;
}

/// ======================= HELPERS =======================

extension _GradientOpacity on Gradient {
  /// สเกลความทึบของ colors ใน Gradient ให้รวมกับ opacity (0..1)
  Gradient scale(double opacity) {
    if (opacity >= 0.999) return this;
    if (this is LinearGradient) {
      final g = this as LinearGradient;
      return LinearGradient(
        begin: g.begin,
        end: g.end,
        stops: g.stops,
        transform: g.transform,
        colors: g.colors
            .map((c) => c.withOpacity(c.opacity * opacity))
            .toList(),
      );
    } else if (this is RadialGradient) {
      final g = this as RadialGradient;
      return RadialGradient(
        center: g.center,
        radius: g.radius,
        focal: g.focal,
        focalRadius: g.focalRadius,
        stops: g.stops,
        transform: g.transform,
        colors: g.colors
            .map((c) => c.withOpacity(c.opacity * opacity))
            .toList(),
      );
    } else if (this is SweepGradient) {
      final g = this as SweepGradient;
      return SweepGradient(
        center: g.center,
        startAngle: g.startAngle,
        endAngle: g.endAngle,
        stops: g.stops,
        transform: g.transform,
        colors: g.colors
            .map((c) => c.withOpacity(c.opacity * opacity))
            .toList(),
      );
    }
    return this;
  }
}
