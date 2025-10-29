// lib/features/Approver/pages/Approver_account_page.dart
import 'package:flutter/material.dart';

class ApproverAccountScreen extends StatelessWidget {
  const ApproverAccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: const Center(child: Text('Approver Account')),
    );
  }
}
