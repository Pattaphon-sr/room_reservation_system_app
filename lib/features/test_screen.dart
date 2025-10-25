import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/shared/overlays/films.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 64, 239, 255),
      body: Center(
        child: GradientBorderBox(
          width: 300,
          height: 150,
          borderRadius: 20,
          borderWidth: 1,
          borderGradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFF065084)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          backgroundColor: const Color(0x14000000),
          shadowGradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // เข้มด้านบน
              Color(0xFF065084), // จางด้านล่าง
            ],
          ),
          shadowBlurSigma: 10,
          shadowOffset: const Offset(0, 6),
          shadowSpread: 2,
          child: const Center(
            child: Text(
              'Outside Gradient Shadow',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
