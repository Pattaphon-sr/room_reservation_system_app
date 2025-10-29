import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Room Reservation',
      home: const InitialScreen(),
    );
  }
}
