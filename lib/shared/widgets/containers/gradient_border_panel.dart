import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/shared/painters/painters.dart';

class GradientBorderPanel extends StatelessWidget {
  const GradientBorderPanel({
    super.key,
    this.width,
    this.height,
    this.strokeWidth = 2,
    this.borderRadius = 20,
    required this.borderGradient,
    this.backgroundColor = Colors.transparent,
    this.backOverlays = const [],
    this.frontOverlays = const [],
    this.child,
  });

  final double? width;
  final double? height;
  final double strokeWidth;
  final double borderRadius;
  final Gradient borderGradient;
  final Color backgroundColor;
  final List<Widget> backOverlays;
  final List<Widget> frontOverlays;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GradientBorderPainter(
        gradient: borderGradient,
        strokeWidth: strokeWidth,
        radius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: backgroundColor)),
              for (final ov in backOverlays)
                Positioned.fill(child: IgnorePointer(child: ov)),
              if (child != null) Positioned.fill(child: child!),
              for (final ov in frontOverlays)
                Positioned.fill(child: IgnorePointer(child: ov)),
            ],
          ),
        ),
      ),
    );
  }
}
