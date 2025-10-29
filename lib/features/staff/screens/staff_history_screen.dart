import 'package:flutter/material.dart';

class StaffHistoryScreen extends StatelessWidget {
  const StaffHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History')),
      body: Center(child: Text('Staff History')),
    );
  }
}
