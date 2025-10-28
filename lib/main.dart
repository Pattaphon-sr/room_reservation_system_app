import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/features/auth/auth.dart';
import 'package:room_reservation_system_app/features/free.dart';
import 'features/test_screen.dart';
import 'features/map_preview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,

      // home: TestScreen(),
      // home: InitialScreen(),
      // home: SignInScreen(),
      // home: SignUpScreen(),
      // home: FloorEditorScreen(),
      home: MapPreview(),
    );
  }
}
