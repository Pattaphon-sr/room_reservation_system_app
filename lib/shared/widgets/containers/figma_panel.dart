import 'dart:ui';
import 'package:flutter/material.dart';

enum StrokePosition { inside, center, outside }

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

class ShadowSpec {
  final Color? color;
  final Gradient? gradient;
  final double offsetX, offsetY;
  final double blurSigma;
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

class FillLayer {
  final Color? color;
  final Gradient? gradient;
  final double opacity;
  final bool onTopOfChild;
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

class FigmaPanel extends StatelessWidget {
  const FigmaPanel({
    super.key,
    this.width,
    this.height, // ถ้า null = ให้คอนเทนต์เป็นตัวกำหนด
    this.borderRadius = 24,
    this.stroke,
    this.shadow,
    this.backgroundBlurSigma = 0,
    this.fills = const <FillLayer>[],
    this.child,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final StrokeSpec? stroke;
  final ShadowSpec? shadow;
  final double backgroundBlurSigma;
  final List<FillLayer> fills;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(borderRadius);

    // เนื้อหา “ภายใน” ที่กำหนดขนาดจริง ๆ
    final content = ClipRRect(
      borderRadius: r,
      child: SizedBox(
        width: width,
        height: height, // อนุญาตเป็น null → สูงตามเนื้อหา
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
            for (final f in fills.where((f) => !f.onTopOfChild))
              Positioned.fill(child: _buildFill(f)),
            if (child != null) Positioned.fill(child: child!),
            for (final f in fills.where((f) => f.onTopOfChild))
              Positioned.fill(child: _buildFill(f)),
          ],
        ),
      ),
    );

    // ใช้ CustomPaint “ตัวเดียว”:
    // - painter: วาดเงา outside (อิงจากขนาด content)
    // - foregroundPainter: วาด stroke ด้านบนสุด
    return CustomPaint(
      painter: _ShadowPainter(radius: borderRadius, shadow: shadow),
      foregroundPainter: _StrokePainter(radius: borderRadius, stroke: stroke),
      child: content,
    );
  }

  Widget _buildFill(FillLayer f) {
    final op = f.opacity.clamp(0.0, 1.0);
    if (f.gradient != null) {
      return DecoratedBox(
        decoration: BoxDecoration(gradient: _scaleGradient(f.gradient!, op)),
      );
    }
    return ColoredBox(color: (f.color ?? Colors.transparent).withOpacity(op));
  }
}

class _ShadowPainter extends CustomPainter {
  _ShadowPainter({required this.radius, required this.shadow});
  final double radius;
  final ShadowSpec? shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final s = shadow;
    if (s == null ||
        (s.color == null && s.gradient == null) ||
        s.blurSigma <= 0) {
      return;
    }

    final baseRect = Offset.zero & size;
    final innerR = RRect.fromRectAndRadius(baseRect, Radius.circular(radius));
    final movedRect = baseRect.shift(Offset(s.offsetX, s.offsetY));
    final outerRect = movedRect.inflate(s.spread);
    final outerR = RRect.fromRectAndRadius(
      outerRect,
      Radius.circular(radius + s.spread),
    );

    final ringPath = Path.combine(
      PathOperation.difference,
      Path()..addRRect(outerR),
      Path()..addRRect(innerR),
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

Gradient _scaleGradient(Gradient g, double opacity) {
  if (opacity >= 0.999) return g;
  if (g is LinearGradient) {
    return LinearGradient(
      begin: g.begin,
      end: g.end,
      stops: g.stops,
      transform: g.transform,
      colors: g.colors.map((c) => c.withOpacity(c.opacity * opacity)).toList(),
    );
  } else if (g is RadialGradient) {
    return RadialGradient(
      center: g.center,
      radius: g.radius,
      focal: g.focal,
      focalRadius: g.focalRadius,
      stops: g.stops,
      transform: g.transform,
      colors: g.colors.map((c) => c.withOpacity(c.opacity * opacity)).toList(),
    );
  } else if (g is SweepGradient) {
    return SweepGradient(
      center: g.center,
      startAngle: g.startAngle,
      endAngle: g.endAngle,
      stops: g.stops,
      transform: g.transform,
      colors: g.colors.map((c) => c.withOpacity(c.opacity * opacity)).toList(),
    );
  }
  return g;
}
