import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF78B9B5),
      body: SafeArea(
        child: Center(
          child: FigmaPanel(
            width: 320,
            height: 120,
            borderRadius: 24,

            // Fill 2 ชั้น (เหมือน Fill list ใน Figma)
            fills: const [
              // FillLayer.color(Color(0xFF320A6B), opacity: 0.5),
              FillLayer.gradient(
                LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
                ),
                opacity: 1.0,
                // onTopOfChild: true,  // ถ้าอยากวางทับตัวอักษร
              ),
            ],

            // Stroke (Position: Inside, Weight: 1)
            stroke: const StrokeSpec(
              weight: 1,
              position: StrokePosition.inside,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFF0F828C)],
              ),
            ),

            // Shadow: X=0, Y=4, Blur=24, Spread=-1, สี #320A6B (outside only)
            shadow: const ShadowSpec(
              color: Color(0xFF0F828C),
              offsetX: 0,
              offsetY: 4,
              blurSigma: 6,
              spread: 1,
            ),

            // เปิดเบลอพื้นหลังภายใน (ถ้าต้องการ)
            backgroundBlurSigma: 45,
            child: const Center(
              child: Text(
                'Figma-like Panel2',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
