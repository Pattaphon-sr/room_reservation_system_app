import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/features/auth/initial_screen.dart';
import 'package:room_reservation_system_app/features/map_preview.dart';
import 'package:room_reservation_system_app/features/staff/screens/floor_editor_screen.dart';
import 'package:room_reservation_system_app/features/test_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Room Reservation',
      home: const InitialScreen(),
      // home: TestScreen(),
      // home: FloorEditorScreen(),
    );
  }
}
