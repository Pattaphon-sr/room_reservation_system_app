// lib/features/Staff/pages/Staff_account_page.dart
import 'package:flutter/material.dart';

class StaffAccountScreen extends StatelessWidget {
  const StaffAccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: const Center(child: Text('Staff Account')),
    );
  }
}
