import 'package:flutter/material.dart';

class ApproverHomeScreen extends StatelessWidget {
  const ApproverHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Approver Home')),
    );
  }
}
