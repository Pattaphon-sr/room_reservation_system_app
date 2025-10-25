import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/shared/widgets/containers/figma_panel.dart';

/// พรีเซ็ต 4 แบบ: air / sky / purple / pink
/// ใช้งาน: PanelPresets.air(width: 320, height: 120, child: ...)

class PanelPresets {
  // ===== AIR =====
  static Widget air({
    required double width,
    required double height,
    double borderRadius = 24,
    Widget? child,
  }) {
    return FigmaPanel(
      width: width,
      height: height,
      borderRadius: borderRadius,
      fills: const [
        // ปรับเฉดได้ตามต้องการ
        FillLayer.gradient(
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
          ),
          opacity: 1.0,
        ),
      ],
      stroke: const StrokeSpec(
        weight: 1,
        position: StrokePosition.inside,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFF0F828C)],
        ),
      ),
      shadow: const ShadowSpec(
        color: Color(0xFF0F828C),
        offsetX: 0,
        offsetY: 4,
        blurSigma: 6,
        spread: 1,
      ),
      backgroundBlurSigma: 40,
      child: child,
    );
  }

  // ===== SKY =====
  static Widget sky({
    required double width,
    required double height,
    double borderRadius = 24,
    Widget? child,
  }) {
    return FigmaPanel(
      width: width,
      height: height,
      borderRadius: borderRadius,
      fills: const [
        FillLayer.color(AppColors.mintSoft, opacity: 0.7),
        FillLayer.gradient(
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
          ),
          opacity: 1.0,
        ),
      ],
      stroke: const StrokeSpec(
        weight: 1,
        position: StrokePosition.inside,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            AppColors.mintSoft,
            AppColors.tealSoft,
            AppColors.tealPrimary,
          ],
          stops: [0.0, 0.6, 0.8, 1.0],
        ),
      ),
      shadow: const ShadowSpec(
        color: AppColors.primary,
        offsetX: 0,
        offsetY: 4,
        blurSigma: 6,
        spread: 1,
      ),
      backgroundBlurSigma: 40,
      child: child,
    );
  }

  // ===== PURPLE =====
  static Widget purple({
    required double width,
    required double height,
    double borderRadius = 24,
    Widget? child,
  }) {
    return FigmaPanel(
      width: width,
      height: height,
      borderRadius: borderRadius,
      fills: const [
        FillLayer.color(AppColors.purpleDeep, opacity: 0.5),
        FillLayer.gradient(
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
          ),
        ),
      ],
      stroke: const StrokeSpec(
        weight: 1,
        position: StrokePosition.inside,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            AppColors.lavenderGlow,
            AppColors.iris,
            AppColors.grapeDark,
          ],
        ),
      ),
      shadow: const ShadowSpec(
        color: Color(0xFF320A6B),
        offsetX: 0,
        offsetY: 4,
        blurSigma: 6,
        spread: 1,
      ),
      backgroundBlurSigma: 40,
      child: child,
    );
  }

  // ===== PINK =====
  static Widget pink({
    required double width,
    required double height,
    double borderRadius = 24,
    Widget? child,
  }) {
    return FigmaPanel(
      width: width,
      height: height,
      borderRadius: borderRadius,
      fills: const [
        FillLayer.color(AppColors.roseMist, opacity: 0.4),
        FillLayer.gradient(
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x15FF6BB5), Color(0x50FF6BB5)],
          ),
          opacity: 1.0,
        ),
      ],
      stroke: const StrokeSpec(
        weight: 1,
        position: StrokePosition.inside,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            AppColors.roseMist,
            AppColors.roseSoft,
            AppColors.roseBright,
          ],
        ),
      ),
      shadow: const ShadowSpec(
        color: AppColors.roseSoft,
        offsetX: 0,
        offsetY: 4,
        blurSigma: 6,
        spread: 1,
      ),
      backgroundBlurSigma: 40,
      child: child,
    );
  }
}
