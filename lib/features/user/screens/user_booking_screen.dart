// lib/features/user/pages/user_booking_page.dart
import 'package:flutter/material.dart';

class UserBookingScreen extends StatelessWidget {
  const UserBookingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: const Center(child: Text('User Booking')),
    );
  }
}
