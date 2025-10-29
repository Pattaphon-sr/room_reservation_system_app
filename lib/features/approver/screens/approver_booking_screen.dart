// lib/features/Approver/pages/Approver_booking_page.dart
import 'package:flutter/material.dart';

class ApproverBookingScreen extends StatelessWidget {
  const ApproverBookingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: const Center(child: Text('Approver Booking')),
    );
  }
}
