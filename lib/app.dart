import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/features/Approver/screens/approver_request_screen.dart';
import 'package:room_reservation_system_app/features/approver/screens/approver_account_screen.dart';
import 'package:room_reservation_system_app/features/approver/screens/approver_history_screen.dart';
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
      // home: const InitialScreen(),
      // home: const MapPreview(),
      // home: const AccountPage(),
      // home: const Booking(),
      // home: TestScreen(),
      // home: FloorEditorScreen(),
       home:ApproverRequestScreen(),
      // home:ApproverAccountScreen(),
      // home: ApproverHistoryScreen(),
    );
  }
}
