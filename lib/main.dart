import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/features/test_screen.dart';
import 'package:room_reservation_system_app/features/user/booking.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Booking(),
      //home: TestScreen(),
      // home: InitialScreen(),
      // home: SignInScreen(),
      // home: SignUpScreen(),
    );
  }
}
