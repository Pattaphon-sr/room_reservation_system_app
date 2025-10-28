import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/features/approver/dashboard_approver.dart';
import 'package:room_reservation_system_app/features/auth/auth.dart';
import 'package:room_reservation_system_app/features/staff/dashboard_staff.dart';
import 'package:room_reservation_system_app/features/user/dashboard_user.dart';
import 'features/test_screen.dart';

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
      // home: DashboardUser(),
      home: DashboardStaff(),
      // home: DashboardApprover(),
    );
  }
}
