// lib/features/Staff/pages/Staff_booking_page.dart
import 'package:flutter/material.dart';

class StaffBookingScreen extends StatelessWidget {
  const StaffBookingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: const Center(child: Text('Staff Booking')),
    );
  }
}
